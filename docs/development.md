# Development

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

The user has repurposed the existing CurseForge project **1700438** for
Forever Utilities. The GitHub repository description and CurseForge summary use:
“Forever Utilities for WoW Forever: target distance checks with color-coded range indicators.”

Each GitHub addon release automatically uploads its exact ZIP to project 1700438
using the existing `CURSE_FORGE` secret and `CURSEFORGE_PROJECT_ID` variable.
Only `ForeverUtilities-vX.Y.Z` tags and standalone `ForeverUtilities/` packages
are accepted; old swing releases cannot be uploaded through this workflow.
Uploads remain beta pending live validation. A `curseforge-ForeverUtilities-vX.Y.Z.json`
receipt records successful acceptance; moderation may still be pending.
Do not repeat an uncertain upload POST before checking CurseForge Files.

API source used for the Forever 1.60.1 baseline:
https://github.com/Gethe/wow-ui-source/tree/4d5d706b8e01c5ebe01c8dd9b7a07151d8d37069/Interface/AddOns/Blizzard_APIDocumentationGenerated

Automated tests use a simulated client. Live gameplay validation remains pending.

The distance readout uses a dark panel, large outlined white text, and a larger
icon with a solid range-colored border for visibility against terrain. Use
`/futils scale 1.2` to enlarge it further; existing position and scale are preserved.

Native attack-range results can be unavailable. Version 0.1.3 also checks actual
spellbook slots and falls back to Auto Shot range for hunter classification.
`/futils status` reports discovered spell counts and native range availability.

An unbounded result such as `>100 yd` is red and labeled **Out of range**
(beyond the checked spell range). Bounded distance estimates remain blue when
attack-range classification is unavailable. This does not imply every ability
is out of range.
