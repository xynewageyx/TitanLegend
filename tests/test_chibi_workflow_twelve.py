import unittest
from pathlib import Path

WORKFLOW = (Path(__file__).resolve().parents[1] / ".github/workflows/generate-chibi-heroes.yml").read_text(encoding="utf-8")


class ChibiWorkflowTwelveTests(unittest.TestCase):
    def test_model_and_preview_counts(self):
        self.assertEqual(WORKFLOW.count("-eq 12"), 3)
        self.assertIn("grep -qx 12", WORKFLOW)
        self.assertNotIn("-eq 11", WORKFLOW)

    def test_blender_pipeline_checks(self):
        for script in ("tools/generate_chibi.py", "tools/validate_chibi_glb.py", "tools/check_chibi_import.py", "tools/render_chibi_previews.py"):
            self.assertIn(script, WORKFLOW)

    def test_artifacts_uploaded(self):
        self.assertIn("titan-legends-chibi-glb", WORKFLOW)
        self.assertIn("titan-legends-chibi-previews", WORKFLOW)


if __name__ == "__main__":
    unittest.main()
