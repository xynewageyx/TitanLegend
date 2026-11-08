#!/usr/bin/env python3
"""Select failed same-repository PRs for bounded Gemini repairs."""
import json
import os
import subprocess

REPO = os.environ["GITHUB_REPOSITORY"]
MAX_ATTEMPTS = 2
MAX_DISPATCHES_PER_RUN = 5
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
    prs = gh_pages("repos/" + REPO + "/pulls?state=open")
    if not isinstance(prs, list):
        raise RuntimeError("Invalid PR list")

    def get_runs(sha):
        data = gh("repos/" + REPO + "/actions/runs?head_sha=" + sha + "&per_page=100")
        return data.get("workflow_runs", [])

    def get_attempts(number):
        comments = gh_pages("repos/" + REPO + "/issues/" + str(number) + "/comments")
        return sum(
            comment.get("user", {}).get("login") == "github-actions[bot]"
            and "[gemini-repair-attempt]" in comment.get("body", "")
            for comment in comments
        )

    selected = choose_all(prs, get_runs, get_attempts)
    if not selected:
        print("No eligible failed PR")
        return
    dry_run = os.environ.get("GEMINI_MONITOR_DRY_RUN", "").lower() == "true"
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
