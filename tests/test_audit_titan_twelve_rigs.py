"""Regression tests for the twelve-class imported Godot Skeleton3D inventory."""
import unittest

from tools.audit_titan_twelve_rigs import CLASSES, audit


def skeleton(name, bones=None):
    if bones is None:
        bones = [{"name": "Root", "parent": None, "index": 0}]
    return {
        "scene": "res://assets/heroes/chibi/" + name + ".glb",
        "node_path": "Armature/Skeleton3D",
        "bones": bones,
    }


class TwelveClassRigAuditTests(unittest.TestCase):
    def test_complete_twelve_classes_including_death_knight(self):
        data = {"skeletons": [skeleton(name) for name in CLASSES]}
        result = audit(data)
        self.assertEqual(result["expected_classes"], 12)
        self.assertEqual(result["covered_classes"], 12)
        self.assertTrue(result["complete"])
        self.assertEqual([r["class"] for r in result["classes"]], CLASSES)

    def test_missing_death_knight_detected(self):
        data = {"skeletons": [skeleton(name) for name in CLASSES if name != "death_knight"]}
        result = audit(data)
        self.assertFalse(result["complete"])
        self.assertEqual(result["covered_classes"], 11)
        self.assertEqual(result["classes"][-1]["status"], "missing")

    def test_duplicate_skeleton_detected(self):
        data = {"skeletons": [skeleton(name) for name in CLASSES] + [skeleton("warrior")]}
        result = audit(data)
        self.assertFalse(result["complete"])
        self.assertEqual(result["classes"][0]["status"], "multiple")

    def test_empty_skeleton_detected(self):
        data = {"skeletons": [skeleton(name, [] if name == "mage" else None) for name in CLASSES]}
        result = audit(data)
        self.assertFalse(result["complete"])
        mage = next(x for x in result["classes"] if x["class"] == "mage")
        self.assertEqual(mage["status"], "empty")

    def test_other_scenes_do_not_count_as_class_skeletons(self):
        data = {"skeletons": [skeleton(name) for name in CLASSES[:-1]]
                + [{"scene": "res://scenes/character/titan_modular_character.tscn",
                    "bones": [{"name": "Root"}]}]}
        result = audit(data)
        self.assertFalse(result["complete"])
        self.assertEqual(result["classes"][-1]["status"], "missing")


if __name__ == "__main__":
    unittest.main()
