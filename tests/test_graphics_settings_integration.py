import pathlib
import unittest

ROOT = pathlib.Path(__file__).resolve().parents[1]
MANAGER = ROOT / "scripts" / "graphics_quality_manager.gd"
MENU = ROOT / "scripts" / "graphics_settings_menu.gd"
PROJECT = ROOT / "project.godot"
DEVELOPER_OVERLAY = ROOT / "scripts" / "developer_fps_overlay.gd"
ANDROID_WORKFLOW = ROOT / ".github" / "workflows" / "android-debug-apk.yml"


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
        self.assertIn("light.shadow_enabled = allow_shadow and bool(light.get_meta(", code)
        self.assertIn('quality == "medium" and not (light is DirectionalLight3D)', code)
        self.assertIn('effect_multiplier = 0.20 if quality == "low" else 0.35', code)

    def test_initial_scene_visuals_are_registered(self):
        code = MANAGER.read_text(encoding="utf-8")
        ready = code.split("func _ready() -> void:", 1)[1].split("\nfunc ", 1)[0]
        self.assertIn("_rebuild_visual_cache()", ready)
        self.assertLess(ready.index("_rebuild_visual_cache()"), ready.index("apply_settings()"))

    def test_visual_cache_cleanup(self):
        code = MANAGER.read_text(encoding="utf-8")
        self.assertIn("node.tree_exiting.is_connected(exit_callback)", code)
        self.assertIn("node.tree_exiting.connect(exit_callback, CONNECT_ONE_SHOT)", code)
        self.assertIn("cached_visuals.erase(node)", code)
        self.assertIn("func _rebuild_visual_cache()", code)
        self.assertIn("if not is_instance_valid(node):", code)

    def test_adaptive_quality_uses_hysteresis(self):
        code = MANAGER.read_text(encoding="utf-8")
        self.assertIn("if low_samples >= 2:", code)
        self.assertIn("var scale_step := 0.15 if measured_fps < float(target_fps) * 0.55 else 0.1", code)
        self.assertIn("adaptive_scale - scale_step", code)
        self.assertIn("if not is_equal_approx(next_scale, adaptive_scale):", code)
        self.assertIn("elif good_samples >= 6 and adaptive_scale < 1.0:", code)
        self.assertIn("startup_grace_seconds := 10.0", code)
        self.assertIn("if sample_seconds < 5.0:", code)

    def test_adaptive_scale_does_not_reapply_unchanged_visual_profile(self):
        code = MANAGER.read_text(encoding="utf-8")
        self.assertIn("if visual_profile != last_visual_profile:", code)
        self.assertIn("last_visual_profile = visual_profile", code)

    def test_developer_diagnostics_are_opt_in_and_show_render_scale(self):
        code = DEVELOPER_OVERLAY.read_text(encoding="utf-8")
        self.assertIn('OS.has_feature("titan_developer")', code)
        self.assertIn('get_tree().root.scaling_3d_scale', code)
        self.assertIn('Soll-Skalierung: %d%%', code)
        self.assertIn('below_target_samples += 1', code)
        self.assertIn('below_target_samples = 0', code)
        self.assertIn('Unter Ziel: %d%%', code)
        self.assertIn('Ziel: %d', code)
        self.assertIn('Engine.max_fps]', code)
        self.assertIn('\\nAvg:', code)

    def test_developer_apk_does_not_overwrite_public_preview(self):
        workflow = ANDROID_WORKFLOW.read_text(encoding="utf-8")
        self.assertIn('custom_features="titan_developer"', workflow)
        self.assertIn("titan-legends-android-${{ github.event_name", workflow)
        self.assertIn("developer-fps", workflow)
        self.assertIn("if: ${{ !(github.event_name == 'workflow_dispatch' && inputs.developer_fps) }}", workflow)
        self.assertIn("actions/upload-artifact@v4", workflow)

    def test_no_live_fps_overlay(self):
        menu = MENU.read_text(encoding="utf-8")
        self.assertNotIn("performance_label", menu)
        self.assertNotIn("Engine.get_frames_per_second()", menu)
        self.assertIn("Automatische FPS-Optimierung", menu)


if __name__ == "__main__":
    unittest.main()
