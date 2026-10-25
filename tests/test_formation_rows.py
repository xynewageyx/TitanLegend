"""Guard the front/back rows and companion attachment against regressions.

These structural checks do not replace a Godot runtime layout test.
"""
from pathlib import Path
import re
import unittest

SOURCE = (Path(__file__).resolve().parents[1] / "scripts" / "team_formation.gd").read_text(encoding="utf-8")


def method(name: str) -> str:
    match = re.search(r"(?m)^func " + re.escape(name) + r"\(", SOURCE)
    if match is None:
        raise AssertionError(f"Missing method {name}")
    next_func = re.search(r"(?m)^func ", SOURCE[match.end():])
    return SOURCE[match.start():match.end() + next_func.start()] if next_func else SOURCE[match.start():]


class FormationRowsTests(unittest.TestCase):
    def test_tanks_and_melee_dealers_front(self):
        body = method("_formation_position")
        self.assertIn("role_ids[i] == 0", body)
        self.assertIn("role_ids[i] == 1 and class_ids[i] in MELEE_CLASSES", body)
        self.assertIn("MELEE_CLASSES := [0, 1, 5, 10]", SOURCE)
        self.assertIn("-1.7 if in_front else 1.0", body)

    def test_companions_stay_children_of_owner(self):
        body = method("create_team")
        self.assertIn('pet.name = "PassivePet"', body)
        self.assertIn("hero.add_child(pet)", body)

    def test_rebuild_and_defeat_recovery_use_same_positions(self):
        self.assertIn("hero.position = _formation_position(i)", method("create_team"))
        self.assertRegex(method("reset_team_defeat_pose"), r"(?:hero|heroes\[i\])\.position = _formation_position\(i\)")
        self.assertNotIn("POSITIONS[i]", SOURCE)


if __name__ == "__main__":
    unittest.main()
