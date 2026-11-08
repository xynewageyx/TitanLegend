#!/usr/bin/env python3
"""Select failed same-repository PRs for bounded Gemini repairs."""
import json
import os
import re
import subprocess
from collections import Counter
from datetime import datetime, timedelta, timezone

REPO = os.environ["GITHUB_REPOSITORY"]
MAX_ATTEMPTS = 2
MAX_DISPATCHES_PER_RUN = 5
QUOTA_BACKOFF_HOURS = 24
PR_RETRY_COOLDOWN_HOURS = 6
WORKFLOW = "gemini-draft-fix.yml"
CHECKS = {
    "Python Regression Tests",
    "Titan Legends Core Regression",
    "Godot project validation",
}


def gh(*args):
    return json.loads(subprocess.run(
        ["gh", "api", *args], check=True, capture_output=True, text=True
    ).stdout)


def gh_pages(endpoint, max_pages=20):
    """Read bounded paginated API collections without silently truncating at 100."""
    items = []
    for page in range(1, max_pages + 1):
        separator = "&" if "?" in endpoint else "?"
        batch = gh(endpoint + separator + "per_page=100&page=" + str(page))
        if not isinstance(batch, list):
            raise RuntimeError("Unexpected paginated API response")
        items.extend(batch)
        if len(batch) < 100:
            return items
    raise RuntimeError("GitHub pagination limit reached; refusing partial scan")


def comment_time(comment):
    """Return a timezone-aware creation time or None for malformed metadata."""
    try:
        timestamp = datetime.fromisoformat(comment["created_at"].replace("Z", "+00:00"))
        return timestamp if timestamp.tzinfo else None
    except (KeyError, ValueError, TypeError, AttributeError):
        return None


def bot_comment(comment, marker):
    return (comment.get("user", {}).get("login") == "github-actions[bot]"
            and marker in comment.get("body", ""))


def quota_backoff_active(comments, now, hours=QUOTA_BACKOFF_HOURS):
    """Pause all dispatches after a confirmed Gemini 429 reported by the repair bot."""
    cutoff = now - timedelta(hours=hours)
    return any(bot_comment(comment, "[gemini-quota-backoff]")
               and (timestamp := comment_time(comment)) is not None
               and timestamp >= cutoff for comment in comments)


def retry_cooldown_active(comments, now, hours=PR_RETRY_COOLDOWN_HOURS):
    """Leave time for dispatched jobs to complete before another attempt."""
    cutoff = now - timedelta(hours=hours)
    return any(bot_comment(comment, "[gemini-repair-attempt]")
               and (timestamp := comment_time(comment)) is not None
               and timestamp >= cutoff for comment in comments)


def count_chargeable_attempts(comments):
    """Provider-quota failures refund the matching SHA's recorded dispatch attempt."""
    attempts = Counter()
    quota_failures = Counter()
    for comment in comments:
        if comment.get("user", {}).get("login") != "github-actions[bot]":
            continue
        body = comment.get("body", "")
        match = re.search(r"\bfor ([0-9a-f]{40})\b", body)
        if not match:
            continue
        sha = match.group(1)
        if "[gemini-repair-attempt]" in body:
            attempts[sha] += 1
        elif "[gemini-quota-backoff]" in body:
            quota_failures[sha] += 1
    return sum(max(0, count - quota_failures[sha]) for sha, count in attempts.items())


def choose_all(prs, get_runs, get_attempts, limit=MAX_DISPATCHES_PER_RUN):
    """Pure selection: select up to limit independent failed PRs."""
    selected = []
    for pr in prs:
        if pr.get("base", {}).get("ref") != "main":
            continue
        head = pr.get("head", {})
        if head.get("repo", {}).get("full_name") != REPO:
            continue
        sha = head.get("sha")
        if not sha:
            continue
        runs = get_runs(sha)
        # Require all required CI workflows to have completed for the same SHA.
        latest = {}
        for run in sorted(runs, key=lambda item: item.get("created_at", ""), reverse=True):
            if run.get("name") in CHECKS and run.get("head_sha") == sha:
                latest.setdefault(run["name"], run)
        if set(latest) != CHECKS:
            continue
        if any(run.get("status") != "completed" for run in latest.values()):
            continue
        failures = [run for run in latest.values() if run.get("conclusion") == "failure"]
        if not failures:
            continue
        attempts = get_attempts(pr["number"])
        if attempts >= MAX_ATTEMPTS:
            continue
        # Prefer a deterministic failed run; repair one run at a time.
        failures.sort(key=lambda run: (run.get("created_at", ""), run["id"]), reverse=True)
        selected.append({"pr": pr["number"], "run": failures[0]["id"],
                         "attempt": attempts + 1, "sha": sha})
        if len(selected) >= limit:
            break
    return selected


def main():
    now = datetime.now(timezone.utc)
    dry_run = os.environ.get("GEMINI_MONITOR_DRY_RUN", "").lower() == "true"
    if not dry_run:
        since = (now - timedelta(hours=QUOTA_BACKOFF_HOURS)).isoformat(timespec="seconds").replace("+00:00", "Z")
        recent_comments = gh_pages("repos/" + REPO + "/issues/comments?since=" + since
                                   + "&sort=created&direction=desc")
        if quota_backoff_active(recent_comments, now):
            print("PAUSED: Gemini API quota exhausted in last 24 hours; no repair dispatched")
            return

    prs = gh_pages("repos/" + REPO + "/pulls?state=open")
    if not isinstance(prs, list):
        raise RuntimeError("Invalid PR list")

    def get_runs(sha):
        data = gh("repos/" + REPO + "/actions/runs?head_sha=" + sha + "&per_page=100")
        return data.get("workflow_runs", [])

    def get_attempts(number):
        comments = gh_pages("repos/" + REPO + "/issues/" + str(number) + "/comments")
        if retry_cooldown_active(comments, now):
            print("PR", number, "in 6-hour dispatch cooldown")
            return MAX_ATTEMPTS  # Temporarily ineligible; does not consume an attempt.
        return count_chargeable_attempts(comments)

    selected = choose_all(prs, get_runs, get_attempts)
    if not selected:
        print("No eligible failed PR")
        return
    if dry_run:
        for item in selected:
            print("DRY RUN: would dispatch PR", item["pr"], "failed run", item["run"],
                  "attempt", item["attempt"])
        return
    for item in selected:
        # Record attempt before dispatch so retries are bounded even if dispatch fails.
        number = item["pr"]
        body = ("[gemini-repair-attempt] Attempt " + str(item["attempt"]) + "/" +
                str(MAX_ATTEMPTS) + " for " + item["sha"])
        subprocess.run(
            ["gh", "api", "-X", "POST", "repos/" + REPO + "/issues/" + str(number) + "/comments",
             "-f", "body=" + body], check=True,
        )
        subprocess.run(
            ["gh", "workflow", "run", WORKFLOW, "--repo", REPO,
             "-f", "run_id=" + str(item["run"]),
             "-f", "pr_number=" + str(number)], check=True,
        )
        print("Dispatched PR", number, "failed run", item["run"])


if __name__ == "__main__":
    main()
