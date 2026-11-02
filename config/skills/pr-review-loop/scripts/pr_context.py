"""Prints the state of a pull request for the pr-review-loop phases as JSON."""

from __future__ import annotations

import argparse
import json
import subprocess

from pr_lib import MARKER_RE, compress, gh, gh_json, parse_diff, pr_number, repo_name

THREADS_QUERY = """
query($owner: String!, $name: String!, $number: Int!, $after: String) {
  repository(owner: $owner, name: $name) {
    pullRequest(number: $number) {
      reviewThreads(first: 100, after: $after) {
        pageInfo { hasNextPage endCursor }
        nodes {
          id isResolved isOutdated path line startLine diffSide
          comments(first: 50) {
            nodes { databaseId author { login } createdAt body url }
          }
        }
      }
    }
  }
}
"""


def load_threads(repo: str, number: str) -> list[dict]:
    owner, name = repo.split("/")
    threads, after = [], None
    while True:
        args = [
            "api", "graphql",
            "-f", f"query={THREADS_QUERY}",
            "-f", f"owner={owner}", "-f", f"name={name}",
            "-F", f"number={number}",
        ]
        if after:
            args += ["-f", f"after={after}"]
        page = gh_json(*args)["data"]["repository"]["pullRequest"]["reviewThreads"]
        for node in page["nodes"]:
            comments = []
            for comment in node["comments"]["nodes"]:
                marker = MARKER_RE.search(comment["body"])
                comments.append(
                    {
                        "databaseId": comment["databaseId"],
                        "author": (comment["author"] or {}).get("login"),
                        "agent": marker.group(1) if marker else None,
                        "createdAt": comment["createdAt"],
                        "url": comment["url"],
                        "body": MARKER_RE.sub("", comment["body"]).strip(),
                    }
                )
            threads.append(
                {
                    "id": node["id"],
                    "isResolved": node["isResolved"],
                    "isOutdated": node["isOutdated"],
                    "path": node["path"],
                    "line": node["line"],
                    "startLine": node["startLine"],
                    "diffSide": node["diffSide"],
                    "rootCommentId": comments[0]["databaseId"] if comments else None,
                    "comments": comments,
                }
            )
        if not page["pageInfo"]["hasNextPage"]:
            return threads
        after = page["pageInfo"]["endCursor"]


def load_stack(repo: str, pr: dict) -> dict:
    open_prs = gh_json(
        "pr", "list", "--repo", repo, "--state", "open", "--limit", "200",
        "--json", "number,title,baseRefName,headRefName",
    )
    return {
        "mergesInto": next(
            (p for p in open_prs if p["headRefName"] == pr["baseRefName"]), None
        ),
        "mergedIntoThis": [
            p for p in open_prs if p["baseRefName"] == pr["headRefName"]
        ],
    }


def load_checks(repo: str, number: str) -> list[dict] | str:
    # `gh pr checks` exits non-zero when a check fails or is pending, so it
    # does not go through `gh()`.
    done = subprocess.run(
        ["gh", "pr", "checks", number, "--repo", repo,
         "--json", "name,state,bucket,workflow,link"],
        capture_output=True, text=True,
    )
    try:
        return json.loads(done.stdout)
    except json.JSONDecodeError:
        return done.stderr.strip() or "no checks"


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("pr", help="number, #number or URL")
    parser.add_argument("--repo", help="owner/name (default: current repo)")
    args = parser.parse_args()
    number = pr_number(args.pr)
    repo = repo_name(args.repo)
    pr = gh_json(
        "pr", "view", number, "--repo", repo, "--json",
        "number,url,title,body,state,isDraft,baseRefName,headRefName,"
        "headRefOid,mergeStateStatus,mergeable,author",
    )
    diff = parse_diff(gh("pr", "diff", number, "--repo", repo))
    print(
        json.dumps(
            {
                "repo": repo,
                "pr": pr,
                "stack": load_stack(repo, pr),
                "diffLines": {
                    path: {
                        "RIGHT": compress(sides["changedRIGHT"]),
                        "LEFT": compress(sides["changedLEFT"]),
                    }
                    for path, sides in diff.items()
                },
                "threads": load_threads(repo, number),
                "checks": load_checks(repo, number),
            },
            ensure_ascii=False,
            indent=2,
        )
    )


if __name__ == "__main__":
    main()
