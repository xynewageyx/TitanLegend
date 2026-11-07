import unittest
from tools.validate_skeleton3d_inventory import validate


def bone(name, parent=None, index=0, parent_index=-1):
    return {"name": name, "parent": parent, "index": index,
            "parent_index": parent_index, "rest_origin": [0, 0, 0],
            "rest_basis": [[1, 0, 0], [0, 1, 0], [0, 0, 1]]}


def inventory(bones):
    return {"skeletons": [{"scene": "res://test.glb", "bones": bones}], "warnings": []}


class SkeletonInventoryValidationTests(unittest.TestCase):
    def test_valid_hierarchy(self):
        self.assertTrue(validate(inventory([bone("Root"), bone("Head", "Root", 1, 0)]))["valid"])

    def test_missing_parent(self):
        self.assertFalse(validate(inventory([bone("Head", "Missing", 0, 1)]))["valid"])

    def test_parent_cycle(self):
        self.assertFalse(validate(inventory([bone("A", "B", 0, 1), bone("B", "A", 1, 0)]))["valid"])

    def test_index_name_mismatch(self):
        self.assertFalse(validate(inventory([bone("Root"), bone("Head", "Root", 1, 1)]))["valid"])

    def test_duplicate_bone_indices(self):
        self.assertFalse(validate(inventory([bone("Root"), bone("Head", "Root", 0, 0)]))["valid"])

    def test_out_of_order_bone_indices(self):
        self.assertFalse(validate(inventory([bone("Root", index=1), bone("Head", "Root", 0, 1)]))["valid"])

    def test_nonfinite_basis(self):
        b = bone("Root")
        b["rest_basis"][0][0] = float("nan")
        self.assertFalse(validate(inventory([b]))["valid"])

    def test_singular_rest_basis(self):
        b = bone("Root")
        b["rest_basis"][2] = [0, 0, 0]
        self.assertFalse(validate(inventory([b]))["valid"])

    def test_valid_rotated_basis(self):
        b = bone("Root")
        b["rest_basis"] = [[0, -1, 0], [1, 0, 0], [0, 0, 1]]
        self.assertTrue(validate(inventory([b]))["valid"])

    def test_no_skeletons(self):
        self.assertFalse(validate({"skeletons": []})["valid"])

    def test_export_warnings(self):
        d = inventory([bone("Root")])
        d["warnings"] = ["missing scene"]
        self.assertFalse(validate(d)["valid"])


if __name__ == "__main__":
    unittest.main()
