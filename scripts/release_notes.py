"""Build consistent release copy for GitHub and the CurseForge file changelog."""
import argparse
from pathlib import Path
import re
from toolbox import ROOT


def render(version, overview, changelog):
    if not re.fullmatch(r'\d+\.\d+\.\d+', version):
        raise ValueError('Expected a semantic version')
    match = re.search(r'^## ' + re.escape(version) + r'\s*\n(.*?)(?=^## |\Z)', changelog, re.M | re.S)
    if not match or not match[1].strip():
        raise ValueError(f'Add release highlights for {version} to docs/changelog.md')
    if not overview.strip():
        raise ValueError('Project description must not be empty')
    return f"# Forever - Hunter's Friend v{version}\n\n## What changed\n\n{match[1].strip()}\n\n---\n\n{overview.strip()}\n"


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--version', required=True)
    args = parser.parse_args()
    print(render(args.version, (ROOT / 'docs/curseforge-description.md').read_text(),
                 (ROOT / 'docs/changelog.md').read_text()), end='')


if __name__ == '__main__':
    main()
