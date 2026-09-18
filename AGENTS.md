# Forever Utilities workflow

The user changed the project to Forever Utilities: distance checking first,
with the swing bar removed for now. Active code is addons/ForeverUtilities/.
Do not restore the swing bar or duplicate the former hunter addon. Historical
swing releases remain in Git history. This is one utilities addon with separate
modules, not a bundle that installs the retired addons.

Use verified Forever 1.60.x APIs. Respect secret values and missing APIs; never
present fabricated exact yards. Spell checks supply approximate brackets. A
failed minimum-range check can mean too close OR too far. Avoid hardcoded Classic
spell IDs and scan learned spells. Poll only while enabled with a living
target, stopping on target loss, death, disable, and leaving the world.

Runtime modules use the addon's namespace, independent frame names,
ForeverUtilitiesDB, and /futils commands. Keep future module settings and update
lifecycles separate. No dependency on ForeverSwing or ForeverHunterRange.

## Delivery

For each fix/feature: implement, add meaningful checks, bump the TOC (patch fixes,
minor features), run python3 scripts/check.py and git diff --check, then build with
python3 scripts/package.py. Verify the ZIP root is ForeverUtilities/. Install the
same files in the known client's _classic_beta_/Interface/AddOns/ForeverUtilities
folder and compare bytes. Preserve unexpected local edits and live SavedVariables.
Never restart the user's game. Report unavailable installation explicitly.

Commit and push scoped changes to main, then verify CI and the GitHub release
asset. Tags are ForeverUtilities-vX.Y.Z; never overwrite existing releases.
Tooling/docs-only changes do not require a new addon version. The release checker
skips unchanged runtime versions and rejects runtime edits without a version bump.
Distinguish mocked tests from live game validation. Tell the user to restart WoW
for first addon discovery, or /reload for updates to an existing installation.

## Publishing boundary

The user explicitly requested reusing CurseForge project 1700438 for Forever
Utilities on 2026-09-18, superseding the earlier separate-project restriction.
Keep GitHub and CurseForge descriptions aligned with the utilities scope. The
restored uploader accepts only ForeverUtilities-vX.Y.Z tags and standalone
ForeverUtilities ZIPs. Use CURSE_FORGE and CURSEFORGE_PROJECT_ID without reading
or exposing token values. Verify both release jobs and the upload receipt.
Never retry an uncertain upload POST before checking project Files.

Do not publish ignored addons.local.json entries or unrelated local files.

## Descriptions and release copy

Maintain docs/curseforge-description.md as the customer-facing overview. Keep the
root and packaged README aligned. Add exact-version highlights to docs/changelog.md
for every addon release. release_notes.py combines them for the GitHub release;
the CurseForge uploader uses that body as its file changelog. Project-page edits
are separate: do not claim the website description changed merely because an
upload succeeded. With no target the indicator uses 20% opacity; selecting a
target or unlocking restores full visibility without idle polling.

Numeric distance uses UnitDistanceSquared only when checkedDistance is readable
and true and the squared value is finite/nonnegative. Never fabricate a midpoint
or use coordinates to bypass restrictions. Friendly targets may provide numeric
distance; enemy numeric readings are not guaranteed. Clear stale values promptly.

## Toolbox modules

/futils opens the shared selector/settings panel. Modules.lua registers features,
owns lazy creation and per-module settings, and migrates the old flat distance
settings once to ForeverUtilitiesDB.modules.distance. Distance.lua owns the
Distance Checker host and options; Range.lua owns its readings/events. Keep each
future utility isolated under modules.<id>. Register before UI.lua initializes.
Disabling must hide the feature, clear its OnUpdate, and unregister events; do not
construct disabled modules on login. Preserve legacy distance shortcut commands.
Check module isolation, panel interactions, and migration when changing this code.
