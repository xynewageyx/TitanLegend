#!/usr/bin/env python3
"""Select failed same-repository PRs for bounded Gemini repairs."""
import json
import os
import subprocess
import sys

REPO = os.environ["GITHUB_REPOSITORY"]
MAX_ATTEMPTS = 2
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


def choose(prs, get_runs, get_attempts):
    """Pure selection: ignore unrelated runs and stop after two attempts."""
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
        # Fail closed when there are multiple failed checks: repair one run at a time.
        return {"pr": pr["number"], "run": failures[0]["id"], "attempt": attempts + 1}
    return None


def main():
    prs = gh("repos/" + REPO + "/pulls?state=open&per_page=100")
    if not isinstance(prs, list):
        raise RuntimeError("Invalid PR list")

    def get_runs(sha):
        data = gh("repos/" + REPO + "/actions/runs?head_sha=" + sha + "&per_page=100")
        return data.get("workflow_runs", [])

    def get_attempts(number):
        comments = gh("repos/" + REPO + "/issues/" + str(number) + "/comments?per_page=100")
        return sum(
            comment.get("user", {}).get("login") == "github-actions[bot]"
            and "[gemini-repair-attempt]" in comment.get("body", "")
            for comment in comments
        )

    selected = choose(prs, get_runs, get_attempts)
    if selected is None:
        print("No eligible failed PR")
        return
    # Record attempt before dispatch so retries are bounded even if dispatch fails.
    number = selected["pr"]
    body = "[gemini-repair-attempt] Attempt " + str(selected["attempt"]) + "/" + str(MAX_ATTEMPTS)
    subprocess.run(
        ["gh", "api", "-X", "POST", "repos/" + REPO + "/issues/" + str(number) + "/comments",
         "-f", "body=" + body], check=True,
    )
    subprocess.run(
        ["gh", "workflow", "run", WORKFLOW, "--repo", REPO,
         "-f", "run_id=" + str(selected["run"]),
         "-f", "pr_number=" + str(number)], check=True,
    )
    print("Dispatched PR", number, "failed run", selected["run"])


if __name__ == "__main__":
    main()
