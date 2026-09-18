## 0.4.0

- Added the shared utilities toolbox: open `/futils` to select and configure features.
- Distance Checker is now an independent module with its own enabled state, position lock, size controls, and reset button.
- Existing distance preferences migrate automatically into per-module settings.
- Disabled modules are not constructed at login. Disabling Distance Checker stops its updates and removes its event listeners.
- Existing `/futils unlock`, `lock`, `on`, `off`, `scale`, and `reset` commands remain available as distance shortcuts.

Use `/reload`, then `/futils` to open the toolbox. Only Distance Checker is included in this release; the module structure supports future utilities.

## 0.3.1

- Friendly targets without a usable distance reading now show “Friendly target — Distance unavailable” in neutral gray.
- The message uses two lines so it fits the indicator without shrinking the text.
- Available friendly-target distance readings continue to display normally.

Use `/reload` to apply the update.

## 0.3.0

- Shows a live decimal yard reading when the client provides a validated numeric target distance.
- Updates the displayed number every 0.15 seconds while a living target is selected, including friendly targets when supported.
- Retains spell-based brackets whenever numeric distance is unavailable; never invents an exact number or keeps a stale reading.
- Keeps attack-range colors independent of numeric distance, which can differ from combat reach.

Use `/reload`. Exact numeric readings are not guaranteed for enemy targets or restricted areas; `/futils status` reports availability.

## 0.2.1

- Fixed an out-of-range result remaining blue when Auto Shot metadata was unavailable and other spells supplied a bounded distance estimate.
- A confirmed negative ranged-attack check now shows red “Out of range,” even when too close versus too far cannot be determined.
- Added regression checks for the actual red icon border and accent colors.

Use `/reload`, then `/futils status` to confirm v0.2.1. Blue still means a distance bracket is known but no attack-range result is available.

## 0.2.0

- The indicator dims to 20% opacity when no target is selected.
- Selecting a target restores full visibility immediately; unlocking keeps the indicator visible for positioning.
- Out-of-range results remain red, with readable text on a dark panel.
- GitHub release notes and CurseForge build descriptions now include the maintained feature overview and version-specific changes.

Update with `/reload`. Your saved position and scale are preserved.
