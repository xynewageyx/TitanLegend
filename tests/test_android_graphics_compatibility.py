"""Validate Android graphics compatibility without bundling device GPU drivers."""
from pathlib import Path
import re
import unittest

ROOT = Path(__file__).resolve().parents[1]

class AndroidGraphicsCompatibilityTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.project = (ROOT / "project.godot").read_text(encoding="utf-8")
        cls.preset = (ROOT / "export_presets.cfg").read_text(encoding="utf-8")
        cls.workflow = (ROOT / ".github/workflows/android-debug-apk.yml").read_text(encoding="utf-8")

    def test_mobile_renderer_is_compatibility(self):
        self.assertRegex(self.project, r'(?m)^renderer/rendering_method.mobile="gl_compatibility"$')
        self.assertRegex(self.project, r'(?m)^renderer/rendering_method="gl_compatibility"$')

    def test_android_texture_compression_enabled(self):
        self.assertIn("textures/vram_compression/import_etc2_astc=true", self.project)

    def test_arm64_android_export(self):
        self.assertRegex(self.preset, r'(?m)^architectures/arm64-v8a=true$')
        self.assertRegex(self.preset, r'(?m)^architectures/armeabi-v7a=false$')

    def test_godot_templates_provide_native_runtime(self):
        self.assertIn("Godot_v4.7.2-stable_export_templates.tpz", self.workflow)
        self.assertIn("android_debug.apk", self.workflow)
        self.assertIn('test -s build/TitanLegends-debug.apk', self.workflow)

    def test_no_external_gpu_driver_bundles(self):
        # GPU drivers are supplied by Android/OEM, not packaged as arbitrary .so files.
        suspicious = [str(p) for p in ROOT.rglob("libGLES*.so")]
        suspicious += [str(p) for p in ROOT.rglob("libvulkan*.so")]
        self.assertEqual([], suspicious)

if __name__ == "__main__":
    unittest.main()
