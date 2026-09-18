"""Publish an existing release ZIP through CurseForge's official WoW upload API."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import re
import subprocess
import sys
import urllib.error
import urllib.request
import uuid
import zipfile

API = 'https://wow.curseforge.com/api'

class NoRedirect(urllib.request.HTTPRedirectHandler):
    def redirect_request(self, *args, **kwargs):
        return None  # Never forward the API credential to a redirect destination.


def api_request(path, token, data=None, content_type=None):
    headers = {'X-Api-Token': token, 'Accept': 'application/json',
               'User-Agent': 'ForeverSwing-release/1.0'}
    if content_type:
        headers['Content-Type'] = content_type
    request = urllib.request.Request(API + path, data=data, headers=headers)
    try:
        with urllib.request.build_opener(NoRedirect).open(request, timeout=90) as response:
            return json.load(response)
    except urllib.error.HTTPError as error:
        raise RuntimeError(f'CurseForge API returned HTTP {error.code}; check token permissions, project and version availability.') from None
    except (urllib.error.URLError, TimeoutError):
        raise RuntimeError('CurseForge connection failed. If upload had started, check project Files before retrying to avoid a duplicate.') from None


def read_package(archive, tag):
    if not re.fullmatch(r'v\d+\.\d+\.\d+', tag):
        raise ValueError('Release tag must have the form vX.Y.Z')
    with zipfile.ZipFile(archive) as package:
        toc = package.read('ForeverSwing/ForeverSwing.toc').decode('utf-8-sig')
    version = re.search(r'^## Version:\s*(\d+\.\d+\.\d+)\s*$', toc, re.M)
    interface = re.search(r'^## Interface:\s*(\d+)\s*$', toc, re.M)
    if not version or 'v' + version[1] != tag or not interface:
        raise ValueError('ZIP version/interface does not match the selected release')
    value = int(interface[1])
    if value // 10000 != 1 or (value % 10000) // 100 != 60:
        raise ValueError('This publisher only targets the verified Forever 1.60 client family')
    return f'{value // 10000}.{(value % 10000) // 100}.{value % 100}'


def select_version(versions, name):
    matches = [v for v in versions if v.get('name') == name]
    if len(matches) != 1 or not isinstance(matches[0].get('id'), int):
        raise ValueError(f'CurseForge must expose exactly one game version named {name}; found {len(matches)}. Refusing to label this as another WoW version.')
    return matches[0]['id']


def multipart(metadata, archive):
    boundary = 'ForeverSwing' + uuid.uuid4().hex
    data = (f'--{boundary}\r\nContent-Disposition: form-data; name="metadata"\r\n'
            'Content-Type: application/json\r\n\r\n').encode()
    data += json.dumps(metadata).encode() + b'\r\n'
    data += (f'--{boundary}\r\nContent-Disposition: form-data; name="file"; '
             f'filename="{archive.name}"\r\nContent-Type: application/zip\r\n\r\n').encode()
    data += archive.read_bytes() + f'\r\n--{boundary}--\r\n'.encode()
    return data, f'multipart/form-data; boundary={boundary}'


def gh(*args):
    return subprocess.check_output(['gh', *args], text=True)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--tag', required=True)
    parser.add_argument('--dry-run', action='store_true')
    args = parser.parse_args()
    if not re.fullmatch(r'v\d+\.\d+\.\d+', args.tag):
        raise ValueError('Release tag must have the form vX.Y.Z')
    token = os.environ.get('CURSE_FORGE', '')
    project = os.environ.get('CURSEFORGE_PROJECT_ID', '')
    if not token:
        raise ValueError('Missing GitHub Actions secret CURSE_FORGE')
    if not args.dry_run and not re.fullmatch(r'[1-9]\d*', project):
        raise ValueError('Set repository variable CURSEFORGE_PROJECT_ID to the numeric project ID')
    repo = os.environ['GITHUB_REPOSITORY']
    release = json.loads(gh('release', 'view', args.tag, '--repo', repo,
                            '--json', 'assets,body,isDraft,url'))
    if release['isDraft']:
        raise ValueError('Publish the GitHub release before uploading to CurseForge')
    asset_name = f'ForeverSwing-{args.tag[1:]}.zip'
    if sum(a['name'] == asset_name for a in release['assets']) != 1:
        raise ValueError('Expected exactly one versioned addon ZIP in the release')
    folder = Path('dist/curseforge')
    folder.mkdir(parents=True, exist_ok=True)
    gh('release', 'download', args.tag, '--repo', repo, '--pattern', asset_name,
       '--dir', str(folder), '--clobber')
    archive = folder / asset_name
    name = read_package(archive, args.tag)
    digest = hashlib.sha256(archive.read_bytes()).hexdigest()
    receipt_name = f'curseforge-{args.tag}.json'
    if any(a['name'] == receipt_name for a in release['assets']):
        gh('release', 'download', args.tag, '--repo', repo, '--pattern', receipt_name,
           '--dir', str(folder), '--clobber')
        receipt = json.loads((folder / receipt_name).read_text())
        if receipt['sha256'] != digest or str(receipt['projectId']) != project:
            raise ValueError('Existing upload receipt does not match ZIP/project; manual review required')
        print(f'Already uploaded: CurseForge file {receipt["fileId"]}; skipped.')
        return
    version_id = select_version(api_request('/game/versions', token), name)
    print(f'Validated {asset_name}; CurseForge game version {name} = {version_id}.')
    if args.dry_run:
        print('Dry run complete; no upload performed.')
        return
    metadata = {'changelog': release['body'] or release['url'],
                'changelogType': 'markdown', 'displayName': f'ForeverSwing {args.tag}',
                'gameVersions': [version_id], 'releaseType': 'beta'}
    data, content_type = multipart(metadata, archive)
    # Deliberately no retry for a non-idempotent upload POST.
    result = api_request(f'/projects/{project}/upload-file', token, data, content_type)
    file_id = result.get('id')
    if not isinstance(file_id, int) or file_id <= 0:
        raise RuntimeError('Upload response lacked a file ID; inspect CurseForge Files before retrying.')
    receipt_path = folder / receipt_name
    receipt_path.write_text(json.dumps({'projectId': int(project), 'fileId': file_id,
                                        'tag': args.tag, 'sha256': digest,
                                        'gameVersionId': version_id}, indent=2) + '\n')
    print(f'Upload accepted: CurseForge project {project}, file {file_id}. Moderation may still be pending.')
    try:
        gh('release', 'upload', args.tag, str(receipt_path), '--repo', repo)
    except subprocess.CalledProcessError:
        raise RuntimeError(f'Upload succeeded (file {file_id}) but saving the GitHub receipt failed. Do not rerun upload before checking CurseForge.') from None
    summary = os.environ.get('GITHUB_STEP_SUMMARY')
    if summary:
        with open(summary, 'a') as handle:
            handle.write(f'## CurseForge upload\nProject: {project}\n\nFile ID: {file_id}\n\n'
                         f'Release: {args.tag} (beta), WoW {name}\n\nAwait CurseForge approval if pending.\n')

if __name__ == '__main__':
    try:
        main()
    except (ValueError, RuntimeError, KeyError, zipfile.BadZipFile) as error:
        print(f'Error: {error}', file=sys.stderr)
        sys.exit(1)
