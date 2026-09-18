import importlib.util
from pathlib import Path
import tempfile
import unittest
import zipfile

spec = importlib.util.spec_from_file_location('publisher', Path(__file__).parents[1] / 'scripts/curseforge.py')
publisher = importlib.util.module_from_spec(spec)
spec.loader.exec_module(publisher)

class PublisherTests(unittest.TestCase):
    def test_exact_version(self):
        self.assertEqual(publisher.select_version([{'name':'1.60.1','id':42}], '1.60.1'), 42)

    def test_no_fallback_to_classic(self):
        with self.assertRaises(ValueError):
            publisher.select_version([{'name':'1.15.7','id':42}], '1.60.1')

    def test_ambiguous_version(self):
        with self.assertRaises(ValueError):
            publisher.select_version([{'name':'1.60.1','id':42}]*2, '1.60.1')

    def test_zip_tag_and_interface(self):
        with tempfile.TemporaryDirectory() as folder:
            archive = Path(folder)/'ForeverSwing-0.2.0.zip'
            with zipfile.ZipFile(archive,'w') as z:
                z.writestr('ForeverSwing/ForeverSwing.toc', '## Interface: 16001\n## Version: 0.2.0\n')
            self.assertEqual(publisher.read_package(archive,'v0.2.0'),'1.60.1')
            with self.assertRaises(ValueError):
                publisher.read_package(archive,'v0.3.0')
            data, mime = publisher.multipart({'releaseType':'beta'},archive)
            self.assertIn(b'name="metadata"',data)
            self.assertIn(b'name="file"',data)
            self.assertIn(archive.read_bytes(),data)
            self.assertTrue(mime.startswith('multipart/form-data; boundary='))

    def test_untrusted_tag(self):
        with self.assertRaises(ValueError):
            publisher.read_package(Path('unused'), '../v0.2.0')

    def test_no_token_redirect(self):
        self.assertIsNone(publisher.NoRedirect().redirect_request(None,None,None,None,None,None))

if __name__ == '__main__':
    unittest.main()
