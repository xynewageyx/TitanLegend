"""Static checks for lightweight elemental area transitions."""
from pathlib import Path
import unittest

ROOT = Path(__file__).resolve().parents[1]
TRANSITION = (ROOT / "scripts/world_transition.gd").read_text(encoding="utf-8")
BIOME = (ROOT / "scripts/biome_manager.gd").read_text(encoding="utf-8")


class ElementTransitionTests(unittest.TestCase):
    def test_signal_and_all_element_names(self):
        self.assertIn("biome_manager.biome_changed.connect(_on_biome_changed)", TRANSITION)
        self.assertIn("var names: Array = biome_manager.NAMES", TRANSITION)
        self.assertIn("var colors: Array = biome_manager.COLORS", TRANSITION)
        self.assertIn("enum BiomeType { FIRE, WATER, EARTH, NATURE, LIGHT, SHADOW, WIND, ICE, LIGHTNING, CHAOS }", BIOME)

    def test_safe_element_lookup(self):
        self.assertIn("index < 0 or index >= names.size() or index >= colors.size()", TRANSITION)
        self.assertIn("if index == last_biome:", TRANSITION)

    def test_mobile_nonblocking_animated_accent(self):
        self.assertIn("Control.MOUSE_FILTER_IGNORE", TRANSITION)
        self.assertIn("element_bar.color = colors[index].lightened(0.3)", TRANSITION)
        self.assertIn("Tween.TRANS_SINE", TRANSITION)
        self.assertIn("tween.kill()", TRANSITION)


if __name__ == "__main__":
    unittest.main()
