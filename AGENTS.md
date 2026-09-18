# Release policy

The user requests a GitHub release for every addon fix or feature.

For each completed fix or feature:
1. Increment the semantic version in ForeverSwing/ForeverSwing.toc (patch for fixes,
   minor for features) and keep displayed/documented versions consistent.
2. Run Lua syntax checks and tests/test_foreverswing.lua; update relevant tests.
3. Commit and push the change to main. The release workflow packages and publishes
   the versioned ZIP automatically when ForeverSwing files change.
4. Check the Actions run and confirm the GitHub release and ZIP asset exist.
   If the workflow cannot run, build with scripts/package.py and publish with gh.
5. Sync the addon to the user's known local Forever installation when available,
   preserving unexpected local changes. Do not restart or interrupt WoW.

Never overwrite an existing release tag or asset to hide a fix; bump the version.
Documentation-only or tooling-only changes do not require an addon version bump.
