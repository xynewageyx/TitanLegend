"""Static guardrails for class-change notification and reserved tank role.

These are source-level checks; the Godot workflow supplies runtime validation.
"""
from pathlib import Path
import re
import unittest

SOURCE = (Path(__file__).resolve().parents[1] / "scripts" / "team_formation.gd")


def method_text(name: str) -> str:
    text = SOURCE.read_text(encoding="utf-8")
    match = re.search(r"(?m)^func " + re.escape(name) + r"\([^\n]*", text)
    if not match:
        raise AssertionError(f"Missing method: {name}")
    following = re.search(r"(?m)^func ", text[match.end():])
    return text[match.start():match.end() + following.start()] if following else text[match.start():]


class RoleChangeSyncTests(unittest.TestCase):
    def test_class_change_notifies_ui_after_rebuilding(self):
        method = method_text("set_class")
        self.assertRegex(method, r"create_team\(\)\s+team_changed\.emit\(\)\s+return true")

    def test_second_tank_selection_is_rejected(self):
        method = method_text("set_role")
        self.assertIn("if i != slot and role_ids[i] == 0:", method)
        self.assertRegex(method, r"if i != slot and role_ids\[i\] == 0:\s+return false")

    def test_formation_bonus_requires_one_tank(self):
        method = method_text("has_formation_bonus")
        self.assertIn("role_ids.count(0) == 1", method)
        self.assertIn("role_ids.count(1) == 2", method)
        self.assertIn("role_ids.count(2) == 1", method)


if __name__ == "__main__":
    unittest.main()
