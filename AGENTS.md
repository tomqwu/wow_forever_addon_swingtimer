# Standard addon workflow

The user wants every addon fix or feature carried through development, validation,
local installation, and a versioned GitHub release. Complete the full cycle without
asking again for routine installation or publication to this repository.

## Required delivery cycle

1. Inspect the current code and relevant Forever APIs. For combat UI changes,
   respect secret values and use the client-supported APIs. Do not substitute
   Classic or Retail assumptions for verified Forever behavior.
2. Implement the requested change. Add or update meaningful tests for changed
   behavior. Preserve existing user settings unless the request changes them.
3. Increment the semantic version in ForeverSwing/ForeverSwing.toc (patch for fixes,
   minor for features). Keep runtime diagnostics and documentation consistent.
4. Run Lua syntax checks, tests/test_foreverswing.lua, and git diff --check.
   Build the installable ZIP with scripts/package.py. The ZIP must contain
   ForeverSwing/ForeverSwing.toc, not an extra repository directory.
5. Install the same addon files in the user's known local Forever client's
   _classic_beta_/Interface/AddOns/ForeverSwing folder when available. Verify the
   installed files match the release source byte-for-byte. Preserve unexpected
   local changes, and do not modify live SavedVariables or interrupt/restart WoW.
   If the installation is unavailable or blocked, report that explicitly.
6. Commit and push to main. The release workflow tests, packages and publishes
   automatically when ForeverSwing/ changes. Verify the Actions run succeeds
   and the matching GitHub release contains the versioned ZIP. If Actions cannot
   run, use the locally validated ZIP and gh release create as the fallback.
7. Report the behavior change, local installation result, test result and release
   link. Tell the user to /reload for existing-addon code updates or restart WoW
   for first-time addon discovery. Mention any command needed for saved settings.
   Distinguish simulated tests from actual in-game validation.

Never overwrite an existing release tag or asset to hide a fix; bump the version.
Documentation-only or tooling-only changes do not require an addon version bump.

## Visibility behavior to preserve

- Default out-of-combat opacity is 15%, fading over 0.35 seconds.
- Entering combat restores full parent-frame opacity immediately.
- Unlocking or previewing keeps the addon visible.
- /fswing oocalpha 0 allows complete out-of-combat transparency.
- Existing per-bar range dimming remains independent of parent-frame opacity.
- Fade and swing update handlers must stop when idle. The hunter range indicator
  may poll every 0.15s only while enabled with a living attackable target; stop
  on target loss, death, disable, or leaving the world.

## CurseForge publishing

The release workflow also publishes to CurseForge project 1700438 using the
CURSE_FORGE Actions secret and CURSEFORGE_PROJECT_ID repository variable. Verify
both the GitHub release and CurseForge upload job for every addon release. Uploads
are beta until actual in-game validation justifies changing the release type.
Never print or retrieve the secret value. If game version 1.60.x is unavailable,
report the blocker rather than marking the addon compatible with another branch.
If a POST has an uncertain outcome, check CurseForge Files before retrying.

## Forever seal-twisting semantics

Twist of Light carries a replaced seal through an Echo into the next melee
attack. Do not present the old 0.4-second catch window as a Forever requirement.
Cues default off, are labeled as personal references, and must never imply that
an Echo is ready or a twist succeeded. Version 0.2.2 migrates the old promoted
0.4-second setting once; preserve explicit choices after that migration.

Hunter range changes must run `lua tests/test_hunterrange.lua`. Yard labels are
spell-derived brackets, not exact distance; do not hardcode Classic spell IDs or
interpret a failed minimum-range spell check as always too far.
