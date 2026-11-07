"""Synthetic hierarchy-integrity regression tests."""
import unittest
from tools.audit_unity_transform_hierarchies import audit


def node(pid, name, parent, children=()):
    return {"path_id": pid, "name": name, "father": [0, parent],
            "children": [{"path_id": child} for child in children]}


class TransformAuditTests(unittest.TestCase):
    def test_two_identical_roots_are_distinct(self):
        bundle = {"file": "weapon.prefab_ab", "nodes": [
            node(1, "Root", 0, [2]), node(2, "Bone", 1),
            node(3, "Root", 0, [4]), node(4, "Bone", 3)]}
        result = audit(bundle)
        self.assertEqual(result["problems"], [])
        self.assertEqual(len(result["roots"]), 2)
        self.assertEqual(result["roots"][0]["relative_paths_sha256"],
                         result["roots"][1]["relative_paths_sha256"])

    def test_invalid_parent_link_reported(self):
        bundle = {"file": "bad.prefab_ab", "nodes": [
            node(1, "Root", 0, [2]), node(2, "Bone", 9)]}
        result = audit(bundle)
        self.assertTrue(result["problems"])

    def test_cycle_reported(self):
        bundle = {"file": "cyclic.prefab_ab", "nodes": [
            node(1, "Root", 0, [2]), node(2, "Bone", 1, [1])]}
        self.assertTrue(audit(bundle)["problems"])


if __name__ == "__main__":
    unittest.main()
