import unittest
from tools.validate_unity_clip_probe import validate


def row(file, start=0.0, stop=1.0):
    return {'file': file, 'consumed': 64, 'bytes': 64,
            'values': {'m_StartTime': [start], 'm_StopTime': [stop],
                       'm_SampleRate': [30.0, 30.0]}}


class ProbeValidationTests(unittest.TestCase):
    def test_valid_and_zero_duration(self):
        result = validate({'files': 2, 'rows': [row('a'), row('b', stop=0)], 'errors': []})
        self.assertEqual(result['validation_problems'], [])
        self.assertEqual(result['zero_duration_files'], ['b'])

    def test_incomplete_and_duplicate(self):
        bad = row('a')
        bad['consumed'] = 60
        result = validate({'files': 2, 'rows': [bad, row('a')], 'errors': []})
        self.assertEqual(len(result['validation_problems']), 2)

    def test_invalid_duration(self):
        result = validate({'files': 1, 'rows': [row('a', 2, 1)], 'errors': []})
        self.assertIn('negative clip duration a', result['validation_problems'])


if __name__ == '__main__':
    unittest.main()
