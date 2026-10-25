"""Structural visual regression guards for the Android screenshots.

These checks catch accidental reintroduction of the giant sphere boss and
unreadable compact equipment window. They do not render a Godot screenshot.
"""
from pathlib import Path
import re
import unittest

ROOT = Path(__file__).resolve().parents[1]


def gd_method(source: str, name: str) -> str:
    found = re.search(r"(?m)^func " + re.escape(name) + r"\(", source)
    if found is None:
        raise AssertionError(f"Missing Godot function: {name}")
    next_func = re.search(r"(?m)^func ", source[found.end():])
    return source[found.start():found.end() + next_func.start()] if next_func else source[found.start():]


class AndroidVisualRegressionTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.battle = (ROOT / "scripts" / "battle_manager.gd").read_text(encoding="utf-8")
        cls.ui = (ROOT / "scripts" / "ui_manager.gd").read_text(encoding="utf-8")

    def test_boss_is_not_giant_placeholder_orb(self):
        spawn = gd_method(self.battle, "_spawn_enemy_visuals")
        self.assertIn('preload("res://scripts/boss_art.gd")', self.battle)
        self.assertIn("BOSS_ART.build(mob, element_id, is_fusion_boss)", spawn)
        self.assertIn('animation.name = "BossMotion"', spawn)
        self.assertIn('animation.call("configure", mob, element_id, is_fusion_boss)', spawn)
        self.assertNotIn("var size := 2.2 if is_boss else 0.65", spawn)

    def test_boss_events_drive_existing_animations(self):
        self.assertIn('_animate_boss_event("attack_windup")', gd_method(self.battle, "_begin_boss_cast"))
        self.assertIn('_animate_boss_event("attack_release")', gd_method(self.battle, "_resolve_boss_cast"))
        self.assertIn('_animate_boss_event("react_to_hit")', gd_method(self.battle, "_deal_damage_to_enemy"))

    def test_equipment_window_is_large_and_readable(self):
        self.assertIn("action_panel.anchor_top = 0.075", self.ui)
        self.assertIn("action_panel.anchor_bottom = 0.77", self.ui)
        self.assertIn('action_title.add_theme_color_override("font_color", ADVENTURE_THEME.INK)', self.ui)
        self.assertIn('action_detail.add_theme_color_override("font_color", ADVENTURE_THEME.INK)', self.ui)
        self.assertIn('loot_compare_label.add_theme_color_override("font_color", ADVENTURE_THEME.INK)', self.ui)
        self.assertIn("action_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO", self.ui)
        self.assertIn('action_close.name = "ActionClose"', self.ui)


if __name__ == "__main__":
    unittest.main()
