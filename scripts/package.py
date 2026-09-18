"""Package one independent utility. Defaults to ForeverUtilities for compatibility."""
import argparse
from toolbox import ROOT, package


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('addon', nargs='?', default='ForeverUtilities')
    parser.add_argument('--local', action='store_true', help='Allow ignored local registry entries')
    args = parser.parse_args()
    version, archive = package(args.addon, include_local=args.local)
    print(f'version={version}')
    print(f'archive={archive.relative_to(ROOT).as_posix()}')


if __name__ == '__main__':
    main()
