"""Syntax-check and test one utility or all public utilities, without publishing."""
import argparse
import subprocess
from toolbox import ROOT, addon_info, registry


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('addon', nargs='?')
    parser.add_argument('--local', action='store_true', help='Allow ignored local registry entries')
    args = parser.parse_args()
    entries = registry(include_local=args.local)
    names = [args.addon] if args.addon else list(entries)
    for name in names:
        folder, version, entry = addon_info(name, include_local=args.local)
        print(f'Checking {name} {version}', flush=True)
        for source in sorted(folder.rglob('*.lua')):
            subprocess.run(['luac', '-p', str(source)], check=True, cwd=ROOT)
        # Local utilities may keep their own test working directory.
        cwd = ROOT / entry.get('testCwd', '.')
        for test in entry['tests']:
            subprocess.run(['lua', test], check=True, cwd=cwd)
    subprocess.run(['python3', '-m', 'unittest', 'discover', '-s', 'tests', '-p', 'test_*.py'], check=True, cwd=ROOT)


if __name__ == '__main__':
    main()
