# Hunter's Friend development

Active source: `addons/ForeverUtilities/`. The existing folder, TOC filename,
saved-variable name, and release tag prefix remain for upgrade compatibility.
The visible addon name is Forever - Hunter's Friend.

Core.lua guards API values. TargetContext.lua supplies facing and ammo readings.
Range.lua owns the compact display and its event/update lifecycle. Distance.lua
owns the dedicated hunter settings, class gate, and lazy bar creation. UI.lua
provides one settings panel via /fhunter (legacy alias /futils).

Settings migrate once from old flat values or modules.distance to
ForeverUtilitiesDB.hunter. Preserve existing preferences. No module registry or
selector remains. Disabled and non-hunter characters do not create the bar.

Run `python3 scripts/check.py`, `git diff --check`, and
`python3 scripts/package.py`. Follow AGENTS.md for local installation, versioned
GitHub releases, CurseForge receipts, and synchronized marketing descriptions.
