"""Static contract for Android debug APK signing and versioning.

This is a configuration guard, not an APK build or device installation test.
"""
from pathlib import Path
import re
import unittest

ROOT = Path(__file__).resolve().parents[1]
WORKFLOW = ROOT / ".github/workflows/android-debug-apk.yml"
PRESET = ROOT / "export_presets.cfg"


class AndroidPreviewConfigTests(unittest.TestCase):
    def test_android_preset_is_arm64_debug_compatible(self):
        text = PRESET.read_text(encoding="utf-8")
        self.assertIn('name="Android"', text)
        self.assertIn('platform="Android"', text)
        self.assertIn('architectures/arm64-v8a=true', text)
        self.assertRegex(text, r'(?m)^version/code=\d+$')
        self.assertIn('package/unique_name="org.titanlegends.idlerpg"', text)

    def test_stable_signing_is_optional_but_validated(self):
        workflow = WORKFLOW.read_text(encoding="utf-8")
        self.assertIn("secrets.TITAN_DEBUG_KEYSTORE_BASE64", workflow)
        self.assertIn("base64 --decode", workflow)
        self.assertIn('keytool -list -keystore "$HOME/.android/debug.keystore"', workflow)
        self.assertIn("TITAN_DEBUG_KEYSTORE_BASE64 missing", workflow)
        self.assertIn("GODOT_ANDROID_KEYSTORE_DEBUG_PATH", workflow)

    def test_each_build_receives_its_run_number_as_version_code(self):
        text = WORKFLOW.read_text(encoding="utf-8")
        self.assertIn("github.run_number", text)
        self.assertIn('re.subn(r"(?m)^version/code=\\d+$"', text)
        preset = PRESET.read_text(encoding="utf-8")
        changed, count = re.subn(
            r"(?m)^version/code=\d+$",
            "version/code=12345",
            preset,
        )
        self.assertEqual(count, 1)
        self.assertIn("version/code=12345", changed)

    def test_apk_is_uploaded_without_committing_it(self):
        workflow = WORKFLOW.read_text(encoding="utf-8")
        self.assertIn("actions/upload-artifact@v4", workflow)
        self.assertIn("gh release upload", workflow)
        self.assertIn("build/TitanLegends-debug.apk", workflow)


if __name__ == "__main__":
    unittest.main()
