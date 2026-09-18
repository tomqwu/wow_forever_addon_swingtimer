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
attackable target, stopping on target loss, death, disable, and leaving the world.

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

The former swing-specific CurseForge uploader and workflow are removed. Project
1700438 belongs to ForeverSwing and must never receive ForeverUtilities packages.
A new project ID and publishing configuration are required for this addon. Do not
retrieve or expose existing token values. GitHub releases are already authorized
as part of the user's established development workflow.

Do not publish ignored addons.local.json entries or unrelated local files.
