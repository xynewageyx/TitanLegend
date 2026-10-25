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
    def test_class_and_role_changes_emit_once_via_team_rebuild(self):
        rebuild = method_text("create_team")
        self.assertEqual(rebuild.count("team_changed.emit()"), 1)
        for method_name in ("set_class", "set_role"):
            method = method_text(method_name)
            self.assertIn("create_team()", method)
            self.assertNotIn("team_changed.emit()", method)

    def test_old_hero_nodes_detached_before_rebuilding(self):
        rebuild = method_text("create_team")
        self.assertIn("remove_child(hero)", rebuild)
        self.assertLess(rebuild.index("remove_child(hero)"), rebuild.index("heroes.clear()"))
        self.assertLess(rebuild.index("heroes.clear()"), rebuild.index('hero.name = "Hero" + str(i + 1)'))

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
