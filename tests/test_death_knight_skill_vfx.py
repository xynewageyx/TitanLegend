"""Static regression checks for the Death Knight visual routing.

These checks protect class 11's unique effect IDs without changing combat rules.
"""
from pathlib import Path
import unittest

ROOT = Path(__file__).resolve().parents[1]
BATTLE = (ROOT / "scripts/battle_manager.gd").read_text(encoding="utf-8")
VFX = (ROOT / "scripts/skill_vfx_3d_v1.gd").read_text(encoding="utf-8")
INTERRUPTS = (ROOT / "scripts/class_interrupt_skills.gd").read_text(encoding="utf-8")


class DeathKnightSkillVfxTests(unittest.TestCase):
    def test_class_interrupt_has_unique_vfx(self):
        self.assertIn('"Grabesstille"', INTERRUPTS)
        self.assertIn('"interrupt_death_knight"', INTERRUPTS)
        self.assertIn('"interrupt_death_knight": "shadow"', VFX)

    def test_visual_routing_preserves_interrupt_priority(self):
        section = BATTLE.split("func _play_equipped_skill_vfx(", 1)[1].split("\nfunc ", 1)[0]
        self.assertLess(section.index("if choice == 7:"), section.index("elif class_id == 11:"))
        self.assertIn('CLASS_INTERRUPTS.vfx_for_class(class_id)', section)
        for effect in ("death_knight_guard", "death_knight_storm", "death_knight_cleave"):
            self.assertIn('"' + effect + '"', section)

    def test_all_death_knight_effects_are_registered(self):
        for effect in ("death_knight_guard", "death_knight_storm", "death_knight_cleave"):
            self.assertIn('"' + effect + '": "shadow"', VFX)
            self.assertIn('"' + effect + '"', VFX.split("if skill_id.begins_with", 1)[1])
        self.assertIn("skill_id == \"death_knight_storm\"", VFX)
        self.assertIn("skill_id == \"death_knight_guard\"", VFX)

    def test_visuals_do_not_change_combat_damage(self):
        section = BATTLE.split("func _play_equipped_skill_vfx(", 1)[1].split("\nfunc ", 1)[0]
        self.assertNotIn("damage_for_skill", section)
        self.assertNotIn("skill_hit_charge[", section)
        self.assertIn('skill_vfx_node.call("play_skill", effect_id, hero.global_position)', section)


if __name__ == "__main__":
    unittest.main()
