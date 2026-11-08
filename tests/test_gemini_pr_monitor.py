"""Offline tests for opt-in PR repair monitor selection."""
import ast
from pathlib import Path
import unittest

SOURCE = (Path(__file__).resolve().parents[1] / "tools" / "gemini_pr_monitor.py").read_text()
tree = ast.parse(SOURCE)
functions = [node for node in tree.body if isinstance(node, ast.FunctionDef) and node.name == "choose"]
namespace = {"CHECKS": {"Python Regression Tests", "Titan Legends Core Regression", "Godot project validation"},
             "REPO": "owner/game", "MAX_ATTEMPTS": 2}
exec(compile(ast.Module(body=functions, type_ignores=[]), "<monitor>", "exec"), namespace)
choose = namespace["choose"]


def pr(label=True, draft=False, sha="abc"):
    return {"number": 12, "draft": draft, "base": {"ref": "main"},
            "head": {"sha": sha, "repo": {"full_name": "owner/game"}},
            "labels": [{"name": "gemini-auto-fix"}] if label else []}


def runs(sha="abc", conclusion="failure"):
    return [{"name": name, "head_sha": sha, "status": "completed",
             "conclusion": conclusion if name == "Python Regression Tests" else "success",
             "id": index + 10, "created_at": "2026-11-08T12:00:00Z"}
            for index, name in enumerate(namespace["CHECKS"])]


class MonitorSelectionTests(unittest.TestCase):
    def select(self, prs, result=None, attempts=0):
        return choose(prs, lambda sha: runs(sha) if result is None else result,
                      lambda number: attempts)

    def test_selects_failed_opted_in_pr(self):
        self.assertEqual(self.select([pr()])["pr"], 12)

    def test_includes_unlabeled_and_draft_prs(self):
        self.assertEqual(self.select([pr(label=False)])["pr"], 12)
        self.assertEqual(self.select([pr(draft=True)])["pr"], 12)

    def test_stops_after_two_attempts(self):
        self.assertIsNone(self.select([pr()], attempts=2))

    def test_ignores_stale_or_incomplete_checks(self):
        self.assertIsNone(self.select([pr()], result=runs("old")))
        self.assertIsNone(self.select([pr()], result=runs()[:2]))
        self.assertIsNone(self.select([pr()], result=runs(conclusion="success")))

    def test_prefers_newest_failed_workflow_deterministically(self):
        candidates = runs()
        candidates[0]["id"] = 101
        candidates[0]["created_at"] = "2026-11-08T12:30:00Z"
        candidates[1]["conclusion"] = "failure"
        candidates[1]["id"] = 102
        candidates[1]["created_at"] = "2026-11-08T12:45:00Z"
        selected = self.select([pr()], result=candidates)
        self.assertEqual(selected["run"], 102)
        self.assertEqual(selected["sha"], "abc")

    def test_rejects_fork_pr(self):
        candidate = pr()
        candidate["head"]["repo"]["full_name"] = "someone/fork"
        self.assertIsNone(self.select([candidate]))


if __name__ == "__main__":
    unittest.main()
