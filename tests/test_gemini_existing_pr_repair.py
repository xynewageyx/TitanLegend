"""Safety regression checks for opt-in repair of existing PRs."""
from pathlib import Path
import ast
import unittest

ROOT = Path(__file__).resolve().parents[1]
SOURCE = (ROOT / "tools" / "gemini_propose_fix.py").read_text(encoding="utf-8")
WORKFLOW = (ROOT / ".github" / "workflows" / "gemini-draft-fix.yml").read_text(encoding="utf-8")


class ExistingPrRepairTests(unittest.TestCase):
    def test_script_is_valid_python(self):
        ast.parse(SOURCE)

    def test_requires_same_repository(self):
        self.assertNotIn('"gemini-auto-fix" not in labels', SOURCE)
        self.assertIn('head.get("repo", {}).get("full_name")', SOURCE)
        self.assertIn('pr_info.get("state") != "open"', SOURCE)

    def test_rejects_stale_or_unrelated_ci_runs(self):
        self.assertIn('run_info.get("headSha") != expected_head', SOURCE)
        self.assertIn('run_info.get("conclusion") != "failure"', SOURCE)
        self.assertIn('if command("git", "rev-parse", "HEAD").stdout.strip() != expected_head:', SOURCE)

    def test_never_force_pushes_or_merges(self):
        self.assertNotIn('"--force"', SOURCE)
        self.assertNotIn('"--force-with-lease"', SOURCE)
        self.assertNotIn('"merge", PR_NUMBER', SOURCE)
        self.assertIn('"HEAD:refs/heads/" + branch', SOURCE)

    def test_workflow_has_opt_in_pr_input(self):
        self.assertIn('pr_number:', WORKFLOW)
        self.assertIn('TARGET_PR_NUMBER:', WORKFLOW)


if __name__ == "__main__":
    unittest.main()
