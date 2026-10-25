"""Inventory check against the 46 GDScript files in original Update 168.

A file may have changed since that release; this test deliberately checks
presence rather than forcing replacement of later gameplay fixes.
"""
from pathlib import Path
import unittest

ROOT = Path(__file__).resolve().parents[1]
EXPECTED_SCRIPTS = frozenset("""
class_visuals.gd boss_arena.gd world_transition.gd talent_menu.gd visual_factory.gd skill_fx.gd hero_body_profiles_126.gd mob_details.gd class_menu.gd floating_text.gd ad_manager.gd skill_system.gd hero_faces_hands_70.gd element_status_fx.gd camera_follow.gd hero_class_silhouettes_64.gd boss_art.gd save_manager.gd battle_manager.gd nature_art.gd talent_path_diagram.gd boss_abilities.gd hero_detail_44.gd crowd_control.gd hero_polish.gd boss_motion.gd element_debuffs.gd boss_phase_fx.gd boss_intro.gd talent_visual_fx.gd game_manager.gd biome_manager.gd element_impact_fx.gd talent_abilities.gd hero_class_identity_125.gd skill_menu.gd shop_manager.gd hero_combat_motion.gd team_formation.gd skin_shop_menu.gd design_details.gd talent_system.gd audio_manager.gd boss_aura.gd hero_weapons_47.gd ui_manager.gd
""".split())


class OriginalScriptInventoryTests(unittest.TestCase):
    def test_all_46_update168_scripts_are_in_repository(self):
        self.assertEqual(len(EXPECTED_SCRIPTS), 46)
        missing = sorted(
            name for name in EXPECTED_SCRIPTS
            if not (ROOT / "scripts" / name).is_file()
        )
        self.assertEqual(missing, [], "Missing original Update 168 scripts")

    def test_original_inventory_is_documented(self):
        audit = ROOT / "docs" / "UPDATE_168_SOURCE_AUDIT.md"
        self.assertTrue(audit.is_file())
        audit_text = audit.read_text(encoding="utf-8")
        for name in EXPECTED_SCRIPTS:
            self.assertIn("scripts/" + name, audit_text)


if __name__ == "__main__":
    unittest.main()
