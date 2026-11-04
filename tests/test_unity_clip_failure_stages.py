"""Synthetic tests for traced Unity AnimationClip decoder failures."""
import unittest
from tools.audit_unity_clip_failure_stages import audit


class FailureStageTests(unittest.TestCase):
    def test_boundary_overrun_and_other_error(self):
        result = audit({
            "files": 3,
            "rows": [{"file": "ok"}],
            "errors": [
                {"file": "a", "error": "overrun w 104/100 at schema-node 22, start 100, size 4, flags 0x200001"},
                {"file": "b", "error": "bad array path -10 at 132"},
            ],
        })
        self.assertEqual(result["failed"], 2)
        self.assertEqual(result["boundary_start_overruns"], 1)
        self.assertEqual(result["field_counts"], {"w": 1})
        self.assertEqual(len(result["other_errors"]), 1)

    def test_bad_counts_rejected(self):
        with self.assertRaises(ValueError):
            audit({"files": 3, "rows": [], "errors": []})


if __name__ == "__main__":
    unittest.main()
