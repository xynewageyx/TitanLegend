"""Guard Android portrait scaling against top/bottom black letterboxing.

These static checks verify intended Godot settings; an Android screenshot
from a rebuilt APK is still needed to confirm device-specific behavior.
"""
from pathlib import Path
import unittest

ROOT = Path(__file__).resolve().parents[1]


class AndroidPortraitViewportTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.settings = (ROOT / "project.godot").read_text(encoding="utf-8")
        cls.hud = (ROOT / "scripts" / "ui_manager.gd").read_text(encoding="utf-8")

    def test_tall_phones_extend_the_vertical_viewport(self):
        self.assertIn('window/stretch/mode="canvas_items"', self.settings)
        self.assertIn('window/stretch/aspect="keep_width"', self.settings)

    def test_base_resolution_remains_portrait(self):
        self.assertIn("window/size/viewport_width=720", self.settings)
        self.assertIn("window/size/viewport_height=1280", self.settings)
        self.assertIn("window/handheld/orientation=1", self.settings)

    def test_hud_uses_screen_edge_anchors(self):
        self.assertIn("Control.PRESET_TOP_WIDE", self.hud)
        self.assertIn("Control.PRESET_BOTTOM_WIDE", self.hud)


if __name__ == "__main__":
    unittest.main()
