"""Regression tests for Gemini provider-quota backoff and attempt accounting."""
import ast
from collections import Counter
from datetime import datetime, timedelta, timezone
from pathlib import Path
import re
import unittest

ROOT = Path(__file__).resolve().parents[1]
SOURCE = (ROOT / "tools/gemini_pr_monitor.py").read_text()
TREE = ast.parse(SOURCE)
NAMES = {"comment_time", "bot_comment", "quota_backoff_active",
         "retry_cooldown_active", "count_chargeable_attempts"}
FUNCTIONS = [node for node in TREE.body if isinstance(node, ast.FunctionDef)
             and node.name in NAMES]
NS = {"datetime": datetime, "timedelta": timedelta, "Counter": Counter, "re": re,
      "QUOTA_BACKOFF_HOURS": 24, "PR_RETRY_COOLDOWN_HOURS": 6}
exec(compile(ast.Module(body=FUNCTIONS, type_ignores=[]), "<quota>", "exec"), NS)

NOW = datetime(2026, 11, 8, 15, 0, tzinfo=timezone.utc)
SHA_A = "a" * 40
SHA_B = "b" * 40


def comment(body, hours_ago=1, bot=True):
    return {"user": {"login": "github-actions[bot]" if bot else "someone"},
            "body": body,
            "created_at": (NOW - timedelta(hours=hours_ago)).isoformat().replace("+00:00", "Z")}


class QuotaBackoffTests(unittest.TestCase):
    def test_recent_bot_quota_marker_blocks_all_dispatches(self):
        comments = [comment("[gemini-quota-backoff] for " + SHA_A)]
        self.assertTrue(NS["quota_backoff_active"](comments, NOW))
        self.assertFalse(NS["quota_backoff_active"](comments, NOW + timedelta(hours=25)))

    def test_user_comment_cannot_force_backoff_or_refund(self):
        comments = [comment("[gemini-quota-backoff] for " + SHA_A, bot=False),
                    comment("[gemini-repair-attempt] Attempt 1/2 for " + SHA_A)]
        self.assertFalse(NS["quota_backoff_active"](comments, NOW))
        self.assertEqual(NS["count_chargeable_attempts"](comments), 1)

    def test_quota_refund_is_bounded_by_dispatches_and_sha(self):
        comments = [comment("[gemini-repair-attempt] Attempt 1/2 for " + SHA_A),
                    comment("[gemini-quota-backoff] for " + SHA_A),
                    comment("[gemini-quota-backoff] for " + SHA_A),
                    comment("[gemini-repair-attempt] Attempt 1/2 for " + SHA_B)]
        self.assertEqual(NS["count_chargeable_attempts"](comments), 1)

    def test_successful_attempt_still_counts_against_two_attempt_limit(self):
        comments = [comment("[gemini-repair-attempt] Attempt 1/2 for " + SHA_A),
                    comment("[gemini-repair-attempt] Attempt 2/2 for " + SHA_A),
                    comment("[gemini-quota-backoff] for " + SHA_A)]
        self.assertEqual(NS["count_chargeable_attempts"](comments), 1)

    def test_pr_cooldown_prevents_immediate_repeat(self):
        comments = [comment("[gemini-repair-attempt] Attempt 1/2 for " + SHA_A, hours_ago=2)]
        self.assertTrue(NS["retry_cooldown_active"](comments, NOW))
        self.assertFalse(NS["retry_cooldown_active"](comments, NOW + timedelta(hours=7)))

    def test_invalid_timestamp_is_not_treated_as_fresh(self):
        item = comment("[gemini-quota-backoff] for " + SHA_A)
        item["created_at"] = "invalid"
        self.assertFalse(NS["quota_backoff_active"]([item], NOW))

    def test_repair_script_writes_quota_marker_but_not_on_503(self):
        source = (ROOT / "tools/gemini_propose_fix.py").read_text()
        self.assertIn('reason == "Quota exhausted; no further calls"', source)
        self.assertIn('command("gh", "pr", "comment", PR_NUMBER, "--body", quota_marker)', source)
        self.assertIn("    raise SystemExit(1)", source)


if __name__ == "__main__":
    unittest.main()
