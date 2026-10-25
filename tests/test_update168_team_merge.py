"""Regression checks for the imported Update 168 team formation.

The archived original is byte-for-byte checksum-verified. This test also
ensures the live scene keeps the key gameplay changes added after Update 168.
Godot headless parsing and a device test remain separate checks.
"""
import hashlib
from pathlib import Path
import re
import unittest

ROOT = Path(__file__).resolve().parents[1]
ARCHIVE = ROOT / "original_update168" / "scripts" / "team_formation.gd"
ACTIVE = ROOT / "scripts" / "team_formation.gd"
ORIGINAL_SHA256 = "19b26a83c256ed98613cc7ca958e54800ff4651d926a811f89508890e33e95e0"


def method_text(src: str, name: str) -> str:
    result = re.search(r"(?m)^func " + re.escape(name) + r"\(", src)
    if not result:
        raise AssertionError("Missing method " + name)
    rest = re.search(r"(?m)^func ", src[result.end():])
    return src[result.start():result.end() + rest.start()] if rest else src[result.start():]


class Update168TeamMergeTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.original = ARCHIVE.read_bytes()
        cls.active = ACTIVE.read_text(encoding="utf-8")

    def test_archived_original_is_unchanged(self):
        self.assertEqual(hashlib.sha256(self.original).hexdigest(), ORIGINAL_SHA256)

    def test_all_original_functions_survive_merge(self):
        original_functions = set(re.findall(r"(?m)^func ([^(]+)\(", self.original.decode("utf-8")))
        active_functions = set(re.findall(r"(?m)^func ([^(]+)\(", self.active))
        self.assertFalse(original_functions - active_functions)

    def test_full_character_detail_and_protection_effects(self):
        for marker in (
            "HeroPolish.decorate",
            "HeroDetail44.decorate",
            "HeroWeapons47.decorate_pet",
            "DesignDetails.pet",
            "wall_impact_wave",
            "wall_shield_material",
        ):
            self.assertIn(marker, self.active)

    def test_correct_formation_and_passive_pet_parenting(self):
        body = method_text(self.active, "create_team")
        self.assertIn("hero.position = _formation_position(i)", body)
        self.assertIn("hero.add_child(pet)", body)
        self.assertIn("team_changed.emit()", body)
        self.assertIn("heroes.clear()", body)
        self.assertIn("call_deferred(\"_refresh_health_after_rebuild\")", body)

    def test_team_rules_and_afk_cancel_remain(self):
        selection = method_text(self.active, "set_role")
        self.assertIn("if i != slot and role_ids[i] == 0:", selection)
        self.assertIn("return false", selection)
        self.assertIn("func stop_walking()", self.active)
        self.assertIn("func set_pet_element(", self.active)


if __name__ == "__main__":
    unittest.main()
