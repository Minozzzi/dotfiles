"""Shared helpers of the pr-review-loop scripts: gh calls and diff parsing."""

from __future__ import annotations

import json
import re
import subprocess
import sys

MARKER = "<!-- pr-review-loop: agent={agent} -->"
MARKER_RE = re.compile(r"<!-- pr-review-loop: agent=([\w.-]+) -->")
HUNK_RE = re.compile(r"^@@ -(\d+)(?:,(\d+))? \+(\d+)(?:,(\d+))? @@")


def gh(*args: str, input_text: str | None = None) -> str:
    """Runs gh and returns stdout; exits with gh's error on failure."""
    result = subprocess.run(
        ["gh", *args], input=input_text, capture_output=True, text=True
    )
    if result.returncode != 0:
        sys.exit(f"gh {' '.join(args[:3])} failed: {result.stderr.strip()}")
    return result.stdout


def gh_json(*args: str) -> object:
    return json.loads(gh(*args))


def pr_number(value: str) -> str:
    """Accepts 70, #70 or a pull request URL."""
    match = re.search(r"(\d+)\s*$", value.rstrip("/"))
    if not match:
        sys.exit(f"Not a pull request number or URL: {value}")
    return match.group(1)


def repo_name(repo: str | None) -> str:
    if repo:
        return repo
    return gh("repo", "view", "--json", "nameWithOwner", "-q", ".nameWithOwner").strip()


def parse_diff(diff: str) -> dict[str, dict[str, list[list[int]]]]:
    """
    Per file and side, the hunks as [start, end] line ranges a review comment
    may use (GitHub accepts any line inside a hunk), plus the changed lines
    (`+` on RIGHT, `-` on LEFT) that the rubric prefers.
    """
    files: dict[str, dict[str, list]] = {}
    path = old_path = None
    left = right = 0
    for raw in diff.splitlines():
        if raw.startswith("diff --git "):
            path = old_path = None
        elif raw.startswith("--- ") and path is None:
            source = raw[4:]
            old_path = None if source == "/dev/null" else source.removeprefix("a/")
        elif raw.startswith("+++ ") and path is None:
            target = raw[4:]
            # A deleted file is commented under its old name, left side only.
            path = old_path if target == "/dev/null" else target.removeprefix("b/")
            if path:
                files.setdefault(
                    path,
                    {"RIGHT": [], "LEFT": [], "changedRIGHT": [], "changedLEFT": []},
                )
        elif (match := HUNK_RE.match(raw)) and path:
            left, right = int(match.group(1)), int(match.group(3))
            left_count = int(match.group(2) or 1)
            right_count = int(match.group(4) or 1)
            if right_count:
                files[path]["RIGHT"].append([right, right + right_count - 1])
            if left_count:
                files[path]["LEFT"].append([left, left + left_count - 1])
        elif path and raw.startswith("+"):
            files[path]["changedRIGHT"].append(right)
            right += 1
        elif path and raw.startswith("-"):
            files[path]["changedLEFT"].append(left)
            left += 1
        elif path and raw.startswith(" "):
            left += 1
            right += 1
    return files


def compress(lines: list[int]) -> str:
    """[1, 2, 3, 7] -> "1-3,7"."""
    ranges: list[str] = []
    for line in sorted(set(lines)):
        if ranges and line == int(ranges[-1].split("-")[-1]) + 1:
            ranges[-1] = f"{ranges[-1].split('-')[0]}-{line}"
        else:
            ranges.append(str(line))
    return ",".join(ranges)


def hunk_of(hunks: list[list[int]], line: int) -> int | None:
    for index, (start, end) in enumerate(hunks):
        if start <= line <= end:
            return index
    return None
