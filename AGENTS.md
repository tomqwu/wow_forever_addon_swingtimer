# Forever - Hunter's Friend workflow

Dedicated hunter addon, not a modular toolbox. Active code stays in addons/ForeverUtilities/ for upgrade compatibility. Do not restore module selection or the swing bar.

Use verified Forever 1.60.x APIs. Respect secret values and missing APIs; never
present fabricated exact yards. Spell checks supply approximate brackets. A
failed minimum-range check can mean too close OR too far. Avoid hardcoded Classic
spell IDs and scan learned spells. Poll only while enabled with a living
target, stopping on target loss, death, disable, and leaving the world.

Runtime modules use the addon's namespace, independent frame names,
ForeverUtilitiesDB, and /futils commands. Preserve hunter settings and the disabled lifecycle. No dependency on ForeverSwing or ForeverHunterRange.

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
Keep GitHub and CurseForge descriptions aligned with the hunter scope. The
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
upload succeeded. With no target the indicator uses 20% opacity; combat restores full visibility, an out-of-combat target uses 60%, and idle uses 20%. Unlocking does not override fading.

Numeric distance uses UnitDistanceSquared only when checkedDistance is readable
and true and the squared value is finite/nonnegative. Never fabricate a midpoint
or use coordinates to bypass restrictions. Friendly targets may provide numeric
distance; enemy numeric readings are not guaranteed. Clear stale values promptly.

## Dedicated hunter runtime

Distance.lua owns NS.Hunter, lazy bar creation, class gating, and settings.
UI.lua exposes one settings panel through /fhunter, with /futils as an alias.
ForeverUtilitiesDB.hunter is migrated once from modules.distance or legacy flat
settings. Keep the installation folder, saved-variable name, and release prefix
for compatibility. No runtime Modules registry remains. Non-hunters must not
create the bar. Ammo sits below the white range text; keep the 400 × 56 layout.

## Bar layout

Layout.lua owns visual block allocation inside the fixed 400 × 56 bar. Keep range/ammo, combat reminders, pet portrait, and control separate. Blocks do not shift with transient warning state; only feature preferences redistribute width. See docs/bar-layout.md before adding information.
