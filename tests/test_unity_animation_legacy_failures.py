import unittest
from tools.crosscheck_unity_animation_legacy_failures import crosscheck


class CrosscheckTests(unittest.TestCase):
    def test_legacy_and_nonlegacy(self):
        headers = [
            {"file": "old", "legacy": 1, "object_bytes": 12},
            {"file": "new", "legacy": 0, "object_bytes": 8},
        ]
        probe = {
            "rows": [{"file": "new", "bytes": 8}],
            "errors": [{"file": "old", "error": "bad array"}],
        }
        self.assertEqual(
            crosscheck(headers, probe)["breakdown"],
            {"legacy_failed": 1, "nonlegacy_passed": 1},
        )

    def test_missing_file(self):
        with self.assertRaises(ValueError):
            crosscheck(
                [{"file": "old", "legacy": 1, "object_bytes": 12}],
                {"rows": [], "errors": []},
            )

    def test_size_mismatch(self):
        with self.assertRaises(ValueError):
            crosscheck(
                [{"file": "new", "legacy": 0, "object_bytes": 8}],
                {"rows": [{"file": "new", "bytes": 7}], "errors": []},
            )


if __name__ == "__main__":
    unittest.main()
