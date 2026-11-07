"""Synthetic regression tests for strict AnimationClip value-probe reporting."""
import unittest
from tools.summarize_unity_clip_value_probe import summarize


class ProbeSummaryTests(unittest.TestCase):
    def test_error_taxonomy(self):
        report = summarize({
            "files": 4,
            "rows": [{"file": "ok", "values": {"m_SampleRate": [30.0, 30.0]}}],
            "errors": [
                {"file": "a", "error": "overrun w 104/100"},
                {"file": "b", "error": "overrun z 103/100"},
                {"file": "c", "error": "bad array path -1 at 132"}],
        })
        self.assertEqual(report["error_categories"],
                         {"invalid_array_length": 1, "overrun_3_bytes": 1,
                          "overrun_4_bytes": 1})
        self.assertEqual(report["fully_consumed"], 1)

    def test_inconsistent_counts_fail(self):
        with self.assertRaises(ValueError):
            summarize({"files": 2, "rows": [], "errors": []})


if __name__ == "__main__":
    unittest.main()
