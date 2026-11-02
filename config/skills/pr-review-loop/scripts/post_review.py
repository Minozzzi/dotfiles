"""
Publishes one COMMENT review with inline comments on a pull request, after
checking every comment's lines against the diff. Nothing is posted when a line
is invalid: the nearest valid lines are printed instead.
"""

from __future__ import annotations

import argparse
import json
import sys

from pr_lib import MARKER, gh, gh_json, hunk_of, parse_diff, pr_number, repo_name


def nearest(hunks: list[list[int]], line: int) -> str:
    if not hunks:
        return "no hunk on this side"
    starts_ends = [value for hunk in hunks for value in hunk]
    closest = min(starts_ends, key=lambda value: abs(value - line))
    return f"nearest hunk edge: {closest} (hunks: {hunks})"


def validate(comment: dict, diff: dict) -> str | None:
    """The reason the comment cannot be posted, or None."""
    path, side = comment.get("path"), comment.get("side", "RIGHT")
    if side not in ("RIGHT", "LEFT"):
        return f"side must be RIGHT or LEFT, not {side}"
    if path not in diff:
        return f"{path} is not in the diff"
    hunks = diff[path][side]
    line, start = comment.get("line"), comment.get("start_line")
    if not isinstance(line, int):
        return "line is required"
    end_hunk = hunk_of(hunks, line)
    if end_hunk is None:
        return f"line {line} is outside the diff; {nearest(hunks, line)}"
    if start is not None:
        if not isinstance(start, int) or start >= line:
            return "start_line must be a number below line"
        if hunk_of(hunks, start) != end_hunk:
            return f"lines {start}-{line} are not in one hunk; {nearest(hunks, start)}"
    if not comment.get("body", "").strip():
        return "body is empty"
    return None


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("pr", help="number, #number or URL")
    parser.add_argument("review", help="JSON file: {agent, body, comments[]}")
    parser.add_argument("--repo", help="owner/name (default: current repo)")
    parser.add_argument("--dry-run", action="store_true", help="validate only")
    args = parser.parse_args()
    number = pr_number(args.pr)
    repo = repo_name(args.repo)
    with open(args.review, encoding="utf-8") as file:
        review = json.load(file)
    agent = review.get("agent") or "unknown"
    marker = MARKER.format(agent=agent)

    diff = parse_diff(gh("pr", "diff", number, "--repo", repo))
    comments = review.get("comments", [])
    errors = [
        f"comment {index + 1} ({comment.get('path')}:{comment.get('line')}): {reason}"
        for index, comment in enumerate(comments)
        if (reason := validate(comment, diff))
    ]
    if errors:
        print("Nothing posted. Fix these comments first:", file=sys.stderr)
        print("\n".join(f"- {error}" for error in errors), file=sys.stderr)
        sys.exit(1)
    if not review.get("body", "").strip():
        sys.exit("Nothing posted: the review body (summary) is empty.")

    head = gh_json("pr", "view", number, "--repo", repo, "--json", "headRefOid")
    payload = {
        "commit_id": head["headRefOid"],
        "event": "COMMENT",
        "body": f"{review['body'].rstrip()}\n\n{marker}",
        "comments": [
            {
                key: value
                for key, value in {
                    "path": comment["path"],
                    "line": comment["line"],
                    "side": comment.get("side", "RIGHT"),
                    "start_line": comment.get("start_line"),
                    "start_side": comment.get("side", "RIGHT")
                    if comment.get("start_line")
                    else None,
                    "body": f"{comment['body'].rstrip()}\n\n{marker}",
                }.items()
                if value is not None
            }
            for comment in comments
        ],
    }
    if args.dry_run:
        print(f"Valid: {len(comments)} comments on {head['headRefOid'][:7]}.")
        return
    posted = json.loads(
        gh(
            "api", "-X", "POST", f"repos/{repo}/pulls/{number}/reviews",
            "--input", "-",
            input_text=json.dumps(payload, ensure_ascii=False),
        )
    )
    print(f"Posted {len(comments)} comments: {posted['html_url']}")


if __name__ == "__main__":
    main()
