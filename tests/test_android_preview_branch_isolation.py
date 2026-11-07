"""Keep independent Android preview builds from cancelling one another."""
from pathlib import Path
import re
import unittest

WORKFLOW = (Path(__file__).resolve().parents[1]
            / ".github" / "workflows" / "android-debug-apk.yml")


class AndroidPreviewIsolationTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.yaml_text = WORKFLOW.read_text(encoding="utf-8")

    def test_concurrency_is_branch_scoped(self):
        self.assertRegex(
            self.yaml_text,
            r"(?m)^  group: titan-legends-android-\$\{\{ github\.ref \}\}-",
        )
        self.assertIn("cancel-in-progress: true", self.yaml_text)

    def test_every_branch_keeps_run_specific_apk_artifact(self):
        self.assertIn("name: Publish APK as GitHub Actions artifact", self.yaml_text)
        self.assertIn("name: TitanLegends-Android-Debug", self.yaml_text)
        self.assertIn("name: Link branch-specific preview artifact", self.yaml_text)
        self.assertIn("github.ref != 'refs/heads/main'", self.yaml_text)

    def test_only_main_can_update_shared_download_release(self):
        self.assertRegex(
            self.yaml_text,
            r"(?s)- name: Publish direct APK download on GitHub Releases\n"
            r"\s+if: \$\{\{ github\.ref == 'refs/heads/main' && "
            r"!\(github\.event_name == 'workflow_dispatch' && inputs\.developer_fps\) \}\}",
        )
        self.assertIn('tag="android-preview"', self.yaml_text)


if __name__ == "__main__":
    unittest.main()
