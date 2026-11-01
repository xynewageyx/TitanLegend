"""Static regression checks for optional imported chibi models."""
from pathlib import Path
import unittest

ROOT = Path(__file__).resolve().parents[1]
TEAM = (ROOT / "scripts/team_formation.gd").read_text(encoding="utf-8")
BRIDGE = (ROOT / "scripts/chibi_glb_visual.gd").read_text(encoding="utf-8")
GENERATOR = (ROOT / "tools/generate_chibi.py").read_text(encoding="utf-8")

class ChibiGLBIntegrationTests(unittest.TestCase):
    def test_all_eleven_classes_are_mapped(self):
        for name in "warrior paladin druid shaman hunter rogue mage warlock summoner priest brawler".split():
            self.assertIn(name, BRIDGE)
            self.assertIn(name, GENERATOR)

    def test_fallback_when_assets_are_missing(self):
        self.assertIn("ResourceLoader.exists(chibi_path)", TEAM)
        self.assertIn("ResourceLoader.exists(path)", BRIDGE)

    def test_visuals_do_not_change_gameplay_or_equipment(self):
        self.assertIn('hero.get_node_or_null("HeroCombatMotion")', BRIDGE)
        self.assertNotIn("damage =", BRIDGE)
        self.assertNotIn("role_ids", BRIDGE)
        self.assertNotIn("HeroWeapons47", BRIDGE)

    def test_animation_clips_are_present(self):
        for clip in ("Idle", "Walk", "Attack", "Hit", "Dodge"):
            self.assertIn(clip, GENERATOR)
            self.assertIn(clip, BRIDGE)

if __name__ == "__main__":
    unittest.main()
