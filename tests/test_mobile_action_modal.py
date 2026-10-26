"""Structural UI regression checks for the Android jewel/equipment modal.

These checks protect the source layout; visual verification in Godot is separate.
"""
from pathlib import Path
import unittest

ROOT = Path(__file__).resolve().parents[1]
UI = (ROOT / "scripts" / "ui_manager.gd").read_text(encoding="utf-8")
THEME = (ROOT / "scripts" / "adventure_ui_theme.gd").read_text(encoding="utf-8")


class MobileActionModalTests(unittest.TestCase):
    def test_header_close_is_not_inside_long_scroll_list(self):
        head = UI.index('action_header := HBoxContainer.new()')
        close = UI.index('action_close.name = "ActionClose"')
        scroll = UI.index('action_scroll := ScrollContainer.new()')
        first_action = UI.index('action_button = _make_button("Ausführen"')
        self.assertLess(head, close)
        self.assertLess(close, scroll)
        self.assertLess(scroll, first_action)

    def test_action_panel_scales_with_portrait_viewport(self):
        self.assertIn("action_panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)", UI)
        # Layout proportions were expanded for the current portrait HUD.
        # Keep the anchors within the display and leave meaningful room
        # for the scrolling action controls.
        import re
        top = re.search(r"action_panel[.]anchor_top[ ]*=[ ]*([0-9.]+)", UI)
        bottom = re.search(r"action_panel[.]anchor_bottom[ ]*=[ ]*([0-9.]+)", UI)
        self.assertIsNotNone(top)
        self.assertIsNotNone(bottom)
        self.assertGreaterEqual(float(top.group(1)), 0.0)
        self.assertLess(float(top.group(1)), float(bottom.group(1)))
        self.assertLessEqual(float(bottom.group(1)), 1.0)
        self.assertGreaterEqual(float(bottom.group(1)) - float(top.group(1)), 0.35)
        self.assertIn("action_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO", UI)
        self.assertIn("action_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED", UI)

    def test_labels_on_parchment_use_dark_ink(self):
        self.assertIn("ADVENTURE_THEME.title(action_title, 24)", UI)
        self.assertIn('action_detail.add_theme_color_override("font_color", ADVENTURE_THEME.INK)', UI)
        self.assertIn('loot_compare_label.add_theme_color_override("font_color", ADVENTURE_THEME.INK)', UI)
        self.assertIn('font_disabled_color", Color("#493b2c")', THEME)

    def test_switching_to_other_menus_hides_previous_modal(self):
        start = UI.index("func _open_menu(target: String) -> void:")
        end = UI.index("\nfunc ", start + 5)
        section = UI[start:end]
        self.assertLess(section.index("action_panel.hide()"), section.index('if target == "shop":'))
        self.assertIn("move_child(action_panel, get_child_count() - 1)", section)


if __name__ == "__main__":
    unittest.main()
