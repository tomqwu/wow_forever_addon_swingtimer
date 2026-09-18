import importlib.util
import json
import sys
from pathlib import Path
import tempfile
import unittest
import zipfile

spec = importlib.util.spec_from_file_location('toolbox', Path(__file__).parents[1] / 'scripts/toolbox.py')
toolbox = importlib.util.module_from_spec(spec)
spec.loader.exec_module(toolbox)


sys.path.insert(0, str(Path(__file__).parents[1] / 'scripts'))
from release_change import needs_release


class ToolboxTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.entries = {}
        for name in ['One', 'Two']:
            folder = self.root / 'addons' / name
            folder.mkdir(parents=True)
            (folder / f'{name}.toc').write_text('## Version: 1.2.3\nMain.lua\n')
            (folder / 'Main.lua').write_text(f'-- {name}\n')
            self.entries[name] = {'path': f'addons/{name}', 'tests': []}
        (self.root / 'addons.json').write_text(json.dumps({'One': self.entries['One']}))
        (self.root / 'addons.local.json').write_text(json.dumps({'Two': self.entries['Two']}))

    def test_local_opt_in(self):
        self.assertEqual(list(toolbox.registry(self.root)), ['One'])
        with self.assertRaises(ValueError):
            toolbox.package('Two', self.root)
        self.assertEqual(set(toolbox.registry(self.root, True)), {'One', 'Two'})

    def test_independent_zip_root(self):
        for name in ['One', 'Two']:
            version, archive = toolbox.package(name, self.root, True)
            self.assertEqual(version, '1.2.3')
            with zipfile.ZipFile(archive) as package:
                self.assertEqual(set(package.namelist()), {f'{name}/{name}.toc', f'{name}/Main.lua'})

    def test_local_cannot_override_public(self):
        (self.root / 'addons.local.json').write_text(json.dumps({'One': self.entries['Two']}))
        with self.assertRaises(ValueError):
            toolbox.registry(self.root, True)

    def test_missing_toc_dependency(self):
        (self.root / 'addons/One/Main.lua').unlink()
        with self.assertRaises(ValueError):
            toolbox.package('One', self.root)

    def test_unsafe_toc_dependency(self):
        (self.root / 'addons/One/One.toc').write_text('## Version: 1.2.3\n../../addons.json\n')
        with self.assertRaises(ValueError):
            toolbox.package('One', self.root)

    def test_release_migration_does_not_republish(self):
        self.assertFalse(needs_release('0.3.1', '0.3.1', False))
        self.assertTrue(needs_release('0.3.2', '0.3.1', True))
        with self.assertRaises(ValueError):
            needs_release('0.3.1', '0.3.1', True)

    def test_invalid_version(self):
        (self.root / 'addons/One/One.toc').write_text('## Version: latest\n')
        with self.assertRaises(ValueError):
            toolbox.package('One', self.root)


if __name__ == '__main__':
    unittest.main()
