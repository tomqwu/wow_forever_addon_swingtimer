"""Decide whether ForeverUtilities needs a release, without republishing unchanged runtime files."""
import argparse
import os
import re
import subprocess
from toolbox import ROOT, addon_info


def needs_release(current_version, previous_version, runtime_changed):
    if previous_version != current_version:
        return True
    if runtime_changed:
        raise ValueError('ForeverUtilities runtime changed without a TOC version bump')
    return False


def previous_runtime(before, folder):
    result = subprocess.run(['git', 'ls-tree', '-r', '--name-only', f'{before}:{folder}'],
                            cwd=ROOT, capture_output=True, text=True)
    if result.returncode:
        return None
    return {name: subprocess.check_output(['git', 'show', f'{before}:{folder}/{name}'], cwd=ROOT)
            for name in result.stdout.splitlines() if not name.lower().endswith('.md')}


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--before', default=os.environ.get('BEFORE_SHA', 'HEAD^'))
    args = parser.parse_args()
    folder, version, _ = addon_info('ForeverUtilities')
    previous = previous_runtime(args.before, 'addons/ForeverUtilities')
    if previous is None:
        subprocess.run(['git', 'rev-parse', '--verify', args.before + '^{commit}'],
                       cwd=ROOT, check=True, stdout=subprocess.DEVNULL)
        print('required=true')
        return
    match = re.search(rb'^## Version:\s*(\d+\.\d+\.\d+)\s*$', previous['ForeverUtilities.toc'], re.M)
    if not match:
        raise ValueError('Cannot read previous version')
    current = {p.relative_to(folder).as_posix(): p.read_bytes() for p in folder.rglob('*')
               if p.is_file() and p.suffix.lower() != '.md'}
    required = needs_release(version, match[1].decode(), current != previous)
    print(f'required={str(required).lower()}')


if __name__ == '__main__':
    main()
