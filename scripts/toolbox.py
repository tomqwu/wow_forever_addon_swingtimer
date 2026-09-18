"""Shared registry and package logic for independent Forever utility addons."""
import json
from pathlib import Path
import re
import zipfile

ROOT = Path(__file__).resolve().parents[1]


def registry(root=ROOT, include_local=False):
    entries = json.loads((root / 'addons.json').read_text())
    if include_local and (root / 'addons.local.json').exists():
        local = json.loads((root / 'addons.local.json').read_text())
        if entries.keys() & local.keys():
            raise ValueError('Local addons cannot override public registry entries')
        entries.update(local)
    for name, entry in entries.items():
        if not re.fullmatch(r'[A-Za-z][A-Za-z0-9_]*', name):
            raise ValueError('Invalid addon name')
        if not isinstance(entry.get('path'), str) or not isinstance(entry.get('tests'), list):
            raise ValueError(f'Invalid registry entry: {name}')
    return entries


def addon_info(name, root=ROOT, include_local=False):
    entries = registry(root, include_local)
    if name not in entries:
        raise ValueError(f'Unknown addon {name}; local entries require --local')
    entry = entries[name]
    folder = (root / entry['path']).resolve()
    toc = (folder / f'{name}.toc').read_text(encoding='utf-8-sig')
    match = re.search(r'^## Version:\s*(\d+\.\d+\.\d+)\s*$', toc, re.M)
    if not match:
        raise ValueError(f'{name}: expected a semantic TOC version')
    for line in toc.splitlines():
        line = line.strip()
        if not line or line.startswith('#'):
            continue
        resource = (folder / line.replace('\\', '/')).resolve()
        if not resource.is_relative_to(folder) or not resource.is_file():
            raise ValueError(f'{name}: missing or unsafe TOC resource {line}')
    return folder, match[1], entry


def package(name, root=ROOT, include_local=False):
    folder, version, _ = addon_info(name, root, include_local)
    dist = root / 'dist'
    dist.mkdir(exist_ok=True)
    archive = dist / f'{name}-{version}.zip'
    with zipfile.ZipFile(archive, 'w', zipfile.ZIP_DEFLATED) as output:
        for path in sorted(folder.rglob('*')):
            if path.is_symlink():
                raise ValueError('Addon packages cannot contain symlinks')
            if path.is_file():
                output.write(path, Path(name) / path.relative_to(folder))
    return version, archive
