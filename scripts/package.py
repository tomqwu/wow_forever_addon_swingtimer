"""Build an installable ZIP whose root contains the ForeverSwing folder."""
from pathlib import Path
import re
import zipfile

root = Path(__file__).resolve().parents[1]
addon = root / 'ForeverSwing'
match = re.search(r'^## Version:\s*(\d+\.\d+\.\d+)\s*$',
                  (addon / 'ForeverSwing.toc').read_text(), re.MULTILINE)
if not match:
    raise SystemExit('Expected a semantic version in ForeverSwing.toc')
version = match.group(1)
dist = root / 'dist'
dist.mkdir(exist_ok=True)
archive = dist / f'ForeverSwing-{version}.zip'
with zipfile.ZipFile(archive, 'w', zipfile.ZIP_DEFLATED) as package:
    for path in sorted(addon.rglob('*')):
        if path.is_file():
            package.write(path, path.relative_to(root))
print(f'version={version}')
print(f'archive=dist/{archive.name}')
