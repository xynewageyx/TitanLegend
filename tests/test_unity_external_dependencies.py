"""Synthetic tests for external Unity CAB dependency audit."""
import unittest
from tools.audit_unity_external_dependencies import audit


class ExternalDependencyTests(unittest.TestCase):
    def test_shared_cab_reference_is_detected(self):
        path = "archive:/CAB-abc/CAB-abc"
        records = {"a.prefab_ab": [{"fileID": 1, "path": path}],
                   "b.prefab_ab": [{"fileID": 1, "path": path}]}
        result = audit(records)
        self.assertEqual(result["references"], 2)
        self.assertEqual(result["unique_external_paths"], 1)
        self.assertEqual(len(result["shared_external_paths"][path]), 2)
        self.assertFalse(result["issues"])

    def test_duplicate_file_id_is_reported(self):
        records = {"a.prefab_ab": [
            {"fileID": 1, "path": "archive:/CAB-a/CAB-a"},
            {"fileID": 1, "path": "archive:/CAB-b/CAB-b"}]}
        self.assertEqual(result_count(audit(records), "duplicate fileID"), 1)


def result_count(result, reason):
    return sum(issue["reason"] == reason for issue in result["issues"])


if __name__ == "__main__":
    unittest.main()
