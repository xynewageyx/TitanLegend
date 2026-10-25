"""Verify that every file from the 213-file Update 168 archive has a path in GitHub.

This is an inventory guard, NOT an assertion of byte-identical content.
The imported 2026-10-25 baseline intentionally contains later code changes.
"""
from pathlib import Path
import unittest

ROOT = Path(__file__).resolve().parents[1]
ORIGINAL_FILES = """
DESIGN_UPDATE_4.md
DESIGN_UPDATE_5.md
DESIGN_UPDATE_6.md
DESIGN_UPDATE_7.md
DESIGN_UPDATE_8.md
README.md
README_ANIMATION_UPDATE.txt
README_UPDATE.txt
README_UPDATE_72.txt
UPDATE_10.md
UPDATE_100.md
UPDATE_101.md
UPDATE_102.md
UPDATE_103.md
UPDATE_104.md
UPDATE_105.md
UPDATE_106.md
UPDATE_107.md
UPDATE_108.md
UPDATE_109.md
UPDATE_11.md
UPDATE_110.md
UPDATE_111.md
UPDATE_112.md
UPDATE_113.md
UPDATE_114.md
UPDATE_115.md
UPDATE_116.md
UPDATE_117.md
UPDATE_118.md
UPDATE_119.md
UPDATE_12.md
UPDATE_120.md
UPDATE_121.md
UPDATE_122.md
UPDATE_123.md
UPDATE_124.md
UPDATE_125.md
UPDATE_126.md
UPDATE_127.md
UPDATE_128.md
UPDATE_129.md
UPDATE_13.md
UPDATE_130.md
UPDATE_131.md
UPDATE_132.md
UPDATE_133.md
UPDATE_134.md
UPDATE_135.md
UPDATE_136.md
UPDATE_137.md
UPDATE_138.md
UPDATE_139.md
UPDATE_14.md
UPDATE_140.md
UPDATE_141.md
UPDATE_142.md
UPDATE_143.md
UPDATE_144.md
UPDATE_145.md
UPDATE_146.md
UPDATE_147.md
UPDATE_148.md
UPDATE_149.md
UPDATE_15.md
UPDATE_150.md
UPDATE_151.md
UPDATE_152.md
UPDATE_153.md
UPDATE_154.md
UPDATE_155.md
UPDATE_156.md
UPDATE_157.md
UPDATE_158.md
UPDATE_159.md
UPDATE_16.md
UPDATE_160.md
UPDATE_162.md
UPDATE_163.md
UPDATE_164.md
UPDATE_165.md
UPDATE_166.md
UPDATE_167.md
UPDATE_168.md
UPDATE_17.md
UPDATE_18.md
UPDATE_19.md
UPDATE_20.md
UPDATE_22.md
UPDATE_23.md
UPDATE_24.md
UPDATE_25.md
UPDATE_25_PARSERFIX.md
UPDATE_26.md
UPDATE_27.md
UPDATE_29.md
UPDATE_30.md
UPDATE_31.md
UPDATE_32.md
UPDATE_33.md
UPDATE_34.md
UPDATE_35.md
UPDATE_36.txt
UPDATE_37.md
UPDATE_38.md
UPDATE_39.md
UPDATE_40.md
UPDATE_41.md
UPDATE_42.md
UPDATE_43.md
UPDATE_44.md
UPDATE_45.md
UPDATE_46.md
UPDATE_47.md
UPDATE_48.md
UPDATE_49.md
UPDATE_50.md
UPDATE_51.md
UPDATE_53.md
UPDATE_54.md
UPDATE_55.md
UPDATE_56.txt
UPDATE_57.md
UPDATE_58.md
UPDATE_60.md
UPDATE_61.md
UPDATE_62.md
UPDATE_63.md
UPDATE_64_NOTES.txt
UPDATE_65.md
UPDATE_66.md
UPDATE_67.md
UPDATE_68_NOTES.txt
UPDATE_69.md
UPDATE_70.md
UPDATE_71.md
UPDATE_73.txt
UPDATE_74.md
UPDATE_75.md
UPDATE_76.md
UPDATE_78.md
UPDATE_79.txt
UPDATE_80.md
UPDATE_81.md
UPDATE_82.md
UPDATE_83.md
UPDATE_84.md
UPDATE_85.md
UPDATE_86.txt
UPDATE_87.md
UPDATE_88.txt
UPDATE_89.md
UPDATE_9.md
UPDATE_90.md
UPDATE_91.md
UPDATE_92.md
UPDATE_93.md
UPDATE_94.txt
UPDATE_95.md
UPDATE_96.txt
UPDATE_97.md
UPDATE_97.txt
UPDATE_98.txt
hero_combat_motion_original_144.txt
project.godot
scenes/floating_text.tscn
scenes/main.tscn
scripts/ad_manager.gd
scripts/audio_manager.gd
scripts/battle_manager.gd
scripts/biome_manager.gd
scripts/boss_abilities.gd
scripts/boss_arena.gd
scripts/boss_art.gd
scripts/boss_aura.gd
scripts/boss_intro.gd
scripts/boss_motion.gd
scripts/boss_phase_fx.gd
scripts/camera_follow.gd
scripts/class_menu.gd
scripts/class_visuals.gd
scripts/crowd_control.gd
scripts/design_details.gd
scripts/element_debuffs.gd
scripts/element_impact_fx.gd
scripts/element_status_fx.gd
scripts/floating_text.gd
scripts/game_manager.gd
scripts/hero_body_profiles_126.gd
scripts/hero_class_identity_125.gd
scripts/hero_class_silhouettes_64.gd
scripts/hero_combat_motion.gd
scripts/hero_detail_44.gd
scripts/hero_faces_hands_70.gd
scripts/hero_polish.gd
scripts/hero_weapons_47.gd
scripts/mob_details.gd
scripts/nature_art.gd
scripts/save_manager.gd
scripts/shop_manager.gd
scripts/skill_fx.gd
scripts/skill_menu.gd
scripts/skill_system.gd
scripts/skin_shop_menu.gd
scripts/talent_abilities.gd
scripts/talent_menu.gd
scripts/talent_path_diagram.gd
scripts/talent_system.gd
scripts/talent_visual_fx.gd
scripts/team_formation.gd
scripts/ui_manager.gd
scripts/visual_factory.gd
scripts/world_transition.gd
""".split()


class OriginalUpdate168InventoryTests(unittest.TestCase):
    def test_inventory_size_and_uniqueness(self):
        self.assertEqual(len(ORIGINAL_FILES), 213)
        self.assertEqual(len(set(ORIGINAL_FILES)), 213)

    def test_all_original_paths_still_exist(self):
        missing = [name for name in ORIGINAL_FILES if not (ROOT / name).is_file()]
        self.assertEqual(missing, [], f"Missing source files: {missing}")

    def test_original_gd_script_count(self):
        self.assertEqual(sum(name.startswith("scripts/") for name in ORIGINAL_FILES), 46)


if __name__ == "__main__":
    unittest.main()
