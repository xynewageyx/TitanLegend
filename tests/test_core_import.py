"""Static regression checks for Titan Legend's imported Godot 4 source.

Run: python -m unittest discover -s tests -v
These checks are intentionally strict: a missing core script is a failure.
They do NOT substitute for a Godot runtime test.
"""
from pathlib import Path
import re
import unittest

ROOT = Path(__file__).resolve().parents[1]
SCRIPTS = ROOT / "scripts"


def source(name: str) -> str:
    path = SCRIPTS / name
    if not path.is_file():
        raise AssertionError(f"Required Godot script missing: {path.relative_to(ROOT)}")
    return path.read_text(encoding="utf-8")


class ImportedCoreRegressionTests(unittest.TestCase):
    def test_godot_entrypoint(self):
        project = ROOT / "project.godot"
        self.assertTrue(project.is_file(), "project.godot is missing")
        text = project.read_text(encoding="utf-8")
        self.assertIn('run/main_scene="res://scenes/main.tscn"', text)
        self.assertTrue((ROOT / "scenes/main.tscn").is_file())

    def test_team_role_lock_has_no_displacement(self):
        text = source("team_formation.gd")
        self.assertRegex(text, r"func set_role\(slot: int, role: int\) -> bool:")
        body = text.split("func set_role(", 1)[1].split("\nfunc ", 1)[0]
        self.assertIn("role == 0", body)
        self.assertIn("role_ids[i] == 0", body)
        self.assertIn("return false", body)
        self.assertNotRegex(body, r"role_ids\[i\]\s*=\s*1")

    def test_enemy_combat_uses_single_living_tank(self):
        text = source("battle_manager.gd")
        self.assertIn("func _living_tank_slot()", text)
        self.assertIn("func _choose_routine_enemy_target()", text)

    def test_save_manager_is_present(self):
        text = source("save_manager.gd")
        self.assertIn("func save_game()", text)
        self.assertIn("func load_game()", text)

    def test_no_accidental_binary_commits(self):
        for forbidden in ("*.apk", "*.aab", "*.keystore", "*.jks"):
            self.assertEqual(list(ROOT.rglob(forbidden)), [])


if __name__ == "__main__":
    unittest.main()
