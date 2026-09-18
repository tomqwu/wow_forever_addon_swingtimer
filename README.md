# ForeverSwing

<img src="assets/ForeverSwing-CurseForge.png" alt="ForeverSwing icon" width="160">

A lightweight melee swing timer for **World of Warcraft: Forever beta 1.60.1 (69893)**.
Uses the native `PLAYER_SWING` event rather than combat-log parsing.

- Main-hand countdown and optional off-hand bar
- Movable, resizable frame with saved settings
- Smooth fade to 15% opacity outside combat; immediate visibility in combat
- `/fswing oocalpha 0` for fully hidden bars outside combat
- Out-of-range dimming, a 0.4-second reference line and shaded end-of-swing area
- Guards unavailable APIs and restricted values
- No external addon dependencies

## Install

Download this repository and copy the **ForeverSwing** folder into
`<World of Warcraft>/_classic_beta_/Interface/AddOns/`.
The final path must be `AddOns/ForeverSwing/ForeverSwing.toc`.
Restart WoW and enable **ForeverSwing** in the AddOns list.

Run `/fswing unlock` to position it, `/fswing lock` to lock it,
`/fswing test` for a preview, and `/fswing status` for diagnostics.
Attack a hostile target to test real swing events.

## Seal twisting

Forever's Twist of Light uses a seal echo on the next swing. This addon does not
assume the old 0.4-second timing window, detect successful twists, or automate
abilities. `/fswing cue 0.4` enables the reference marker (default for new installs); `/fswing cue 0` disables it.

[Full commands, API research, sources and limitations](ForeverSwing/README.md)

## Validation

Lua syntax checks and 51 model/mock-client checks pass. Live in-game combat,
dungeon and PvP validation is still pending.

Run from the repository root with Lua installed:

```sh
luac -p ForeverSwing/Core.lua
luac -p ForeverSwing/ForeverSwing.lua
lua tests/test_foreverswing.lua
```

## Releases

Download the installable ZIP from [GitHub Releases](https://github.com/tomqwu/wow_forever_addon_swingtimer/releases).
Every addon fix or feature gets a new version. Pushes to `main` that change
`ForeverSwing/` run syntax checks and tests, build a ZIP, and publish the version
from `ForeverSwing.toc`. Existing releases are never overwritten; bump the version
before the next fix or feature. The workflow can also be run manually.

To package locally: `python3 scripts/package.py`.

## Development workflow

Every addon fix or feature follows the delivery cycle in [AGENTS.md](AGENTS.md):
implement and test, bump the version, build the ZIP, install and verify the local
copy when available, push, and verify the GitHub release and asset. Completion
notes include the release link and the required reload/setup commands. Simulated
tests and in-game testing are reported separately.

## CurseForge publishing

Project: [WoW Forever Melee Swing Timer](https://www.curseforge.com/wow/addons/wow-forever-melee-swing-timer)
(project ID `1700438`).

The release workflow calls **Publish to CurseForge** after creating the GitHub
release. It uploads that exact release ZIP as a **beta**, using repository secret
`CURSE_FORGE` and repository variable `CURSEFORGE_PROJECT_ID`. No token is stored
in source or passed in URLs. The uploader resolves the exact `1.60.1` game-version
ID through CurseForge's API; it fails instead of substituting a Classic/Retail tag
when Forever is unavailable.

To publish an existing release, run **Actions → Publish to CurseForge → Run
workflow**, enter a tag such as `v0.2.0`, and turn off **dry_run**. A dry run checks
the package and authenticated version API without uploading. The project may
require CurseForge moderation after an upload is accepted.

Successful uploads attach a `curseforge-vX.Y.Z.json` receipt to the GitHub release,
so reruns with that receipt skip the upload. An interrupted upload or a failure to
save the receipt needs a manual check of CurseForge Files before retrying; upload
POSTs are never automatically retried. Do not change/delete a published release ZIP.

Publisher tests: `python3 -m unittest discover -s tests -p 'test_curseforge.py'`.

API reference: [CurseForge Upload API](https://support.curseforge.com/support/solutions/articles/9000197321).
