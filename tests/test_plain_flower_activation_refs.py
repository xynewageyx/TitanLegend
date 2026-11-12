"""Source-independent tests for local Unity PPtr filtering."""
import unittest
from collections import Counter
from tools.audit_plain_flower_activation_refs import pointer_ids, assess_coverage


class PointerTests(unittest.TestCase):
    def test_only_explicit_pptrs(self):
        tree = {"m_GameObject": {"m_FileID": 0, "m_PathID": 123},
                "m_Script": {"m_FileID": 1, "m_PathID": 88},
                "number": 123, "other": {"m_PathID": 99},
                "items": [{"link": {"m_FileID": 0, "m_PathID": 456}}]}
        self.assertEqual(set(pointer_ids(tree)), {(0, 123), (1, 88), (0, 456)})

    def test_complete_saved_scene_counts(self):
        self.assertEqual(assess_coverage(105075, 28709, Counter(), 10), [])

    def test_mismatched_source_count_is_incomplete(self):
        self.assertIn("serialized_object_count_mismatch", assess_coverage(105074, 28709, Counter(), 10))

    def test_unreadable_component_is_incomplete(self):
        self.assertIn("unreadable_type_trees", assess_coverage(105075, 28709, Counter({"MonoBehaviour": 1}), 10))

    def test_empty(self):
        self.assertEqual(list(pointer_ids({"none": [1, "x", None]})), [])


if __name__ == "__main__":
    unittest.main()
