"""Source-independent tests for local Unity PPtr filtering."""
import unittest
from collections import Counter
from tools.audit_plain_flower_activation_refs import pointer_ids, assess_coverage, inspect_group_components


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

    def test_group_inactive_with_single_transform(self):
        data = {"m_IsActive": False, "m_Component": [
            {"component": {"m_FileID": 0, "m_PathID": 77}}]}
        refs, issues = inspect_group_components(data, {77: "Transform"})
        self.assertEqual(refs, [(0, 77)])
        self.assertEqual(issues, [])

    def test_group_active_is_not_accepted(self):
        data = {"m_IsActive": True, "m_Component": [
            {"component": {"m_FileID": 0, "m_PathID": 77}}]}
        self.assertIn("group_not_serialized_inactive",
                      inspect_group_components(data, {77: "Transform"})[1])

    def test_group_with_wrong_component_class_is_not_accepted(self):
        data = {"m_IsActive": False, "m_Component": [
            {"component": {"m_FileID": 0, "m_PathID": 77}}]}
        self.assertIn("group_component_not_local_transform",
                      inspect_group_components(data, {77: "MonoBehaviour"})[1])

    def test_group_with_extra_component_is_not_accepted(self):
        data = {"m_IsActive": False, "m_Component": [
            {"component": {"m_FileID": 0, "m_PathID": 77}},
            {"component": {"m_FileID": 0, "m_PathID": 88}}]}
        self.assertIn("unexpected_group_component_count",
                      inspect_group_components(data, {77: "Transform", 88: "MonoBehaviour"})[1])

    def test_empty(self):
        self.assertEqual(list(pointer_ids({"none": [1, "x", None]})), [])


if __name__ == "__main__":
    unittest.main()
