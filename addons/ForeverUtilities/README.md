# Forever Utilities

A lightweight utilities addon for **World of Warcraft: Forever**. The first
utility is a target distance checker: an icon that changes color with a label
showing an approximate yard bracket. There is no swing bar.

## Distance checker

Select a living hostile target. The icon updates as either of you moves:

| Color | Meaning |
| --- | --- |
| Green | In native ranged auto-attack range |
| Amber | In native melee range |
| Orange | Confirmed too close for ranged auto attack |
| Red | Confirmed beyond ranged auto-attack range |
| Gray | Ambiguous/unavailable status, or no valid target |

The label shows spell-based brackets such as `<=5 yd`, `~8-35 yd`, or `>35 yd`.
These are **approximate ranges, not exact distance measurements**. The utility
uses learned spells and their current metadata instead of fixed Classic spell
IDs. Available spells, target combat reach, and API restrictions affect precision.
It works on all classes; the close/shooting/far distinctions are most useful for
hunters. A gray icon can still show a known yard bracket when ranged status is
ambiguous. Green does not guarantee facing, line of sight, ammo, or readiness.

## Install and use

Extract `ForeverUtilities/` from the release ZIP into
`<World of Warcraft>/_classic_beta_/Interface/AddOns/`.
Restart WoW for first discovery and enable **Forever Utilities**.
Existing addon updates can use `/reload`.

- `/futils unlock` — drag the icon; `/futils lock` — lock it.
- `/futils on` or `/futils off` — enable or disable distance checking.
- `/futils scale 1.2` — resize (0.5–2).
- `/futils reset` — reset this addon's settings only.
- `/futils status` — show version and availability.

The icon has independent position and settings in `ForeverUtilitiesDB`, remains
visible outside combat, and does not depend on other addons. Range checks update
at most every 0.15 seconds while enabled with a living attackable target.

## Repository layout

```text
addons/ForeverUtilities/   Installable addon (Core.lua, Range.lua, UI.lua, TOC)
addons.json               Source and test registry
scripts/check.py          Syntax, addon, and tooling validation
scripts/package.py        Create one installable ZIP
scripts/release_change.py  Require a new version for runtime changes
tests/                    Mock-client and packaging/release checks
.github/workflows/        CI and GitHub release automation
```

Build from the repository root with Python 3.10+ and Lua/luac 5.1:

```sh
python3 scripts/check.py
python3 scripts/package.py
```

The ZIP is `dist/ForeverUtilities-X.Y.Z.zip`, with `ForeverUtilities/` directly
inside it. Releases use `ForeverUtilities-vX.Y.Z` tags. Pushes changing the addon
run validation, package it, and release a new TOC version. Unchanged runtime
versions are skipped; runtime edits without a version bump fail. Other utilities
can be added as independent modules with their own settings and lifecycle rules.

Optional developer-only addon registry entries can be placed in ignored
`addons.local.json` and selected with `--local`; they are not included in CI or
published automatically.

## Migration and publishing

This repository previously contained ForeverSwing. Its swing bar is removed
from the current source. Historical tags and releases remain available.
The separate local ForeverHunterRange prototype is superseded by the distance
module here. Disable the old addons if installing this manually to avoid duplicate
UI. Their saved settings are not modified or imported.

The old swing-timer CurseForge workflow is retired. **Forever Utilities is not
uploaded to the swing timer's CurseForge project.** A separate project must be
configured before enabling CurseForge publishing for this addon. GitHub releases
continue in this repository.

API source used for the Forever 1.60.1 baseline:
https://github.com/Gethe/wow-ui-source/tree/4d5d706b8e01c5ebe01c8dd9b7a07151d8d37069/Interface/AddOns/Blizzard_APIDocumentationGenerated

Automated tests use a simulated client. Live gameplay validation remains pending.
