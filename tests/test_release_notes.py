import sys
from pathlib import Path
import unittest
sys.path.insert(0,str(Path(__file__).parents[1]/'scripts'))
from release_notes import render

class ReleaseNotesTests(unittest.TestCase):
    def test_selects_exact_version_and_includes_description(self):
        result=render('0.2.0','# Product\nOverview.', '## 0.2.0\nNew changes.\n## 0.1.0\nOld changes.')
        self.assertIn('New changes.',result)
        self.assertIn('Overview.',result)
        self.assertNotIn('Old changes.',result)
    def test_missing_version_fails_instead_of_publishing_stale_notes(self):
        with self.assertRaises(ValueError): render('0.3.0','Overview','## 0.2.0\nOld notes')
    def test_empty_description_rejected(self):
        with self.assertRaises(ValueError): render('0.2.0','', '## 0.2.0\nNotes')
