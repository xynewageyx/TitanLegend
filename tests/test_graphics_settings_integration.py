import pathlib
import unittest

ROOT = pathlib.Path(__file__).resolve().parents[1]
MANAGER = ROOT / "scripts" / "graphics_quality_manager.gd"
MENU = ROOT / "scripts" / "graphics_settings_menu.gd"
PROJECT = ROOT / "project.godot"


class GraphicsSettingsIntegrationTests(unittest.TestCase):
    def test_autoloads_registered(self):
        project = PROJECT.read_text(encoding="utf-8")
        self.assertIn('GraphicsQualityManager="*res://scripts/graphics_quality_manager.gd"', project)
        self.assertIn('GraphicsSettingsMenu="*res://scripts/graphics_settings_menu.gd"', project)

    def test_saved_player_settings_and_opt_in(self):
        code = MANAGER.read_text(encoding="utf-8")
        for token in ("func save_settings()", "func load_settings()", "func set_preset(",
                      "func set_custom(", "func set_automatic(", "if not automatic_optimization:"):
            self.assertIn(token, code)

    def test_dynamic_effects_respect_profile(self):
        code = MANAGER.read_text(encoding="utf-8")
        self.assertIn("node_added.connect(_on_node_added)", code)
        self.assertIn("func _on_node_added(", code)
        self.assertIn("GPUParticles3D", code)
        self.assertIn("shadow_enabled = shadows_enabled", code)

    def test_no_live_fps_overlay(self):
        menu = MENU.read_text(encoding="utf-8")
        self.assertNotIn("performance_label", menu)
        self.assertNotIn("Engine.get_frames_per_second()", menu)
        self.assertIn("Automatische FPS-Optimierung", menu)


if __name__ == "__main__":
    unittest.main()
