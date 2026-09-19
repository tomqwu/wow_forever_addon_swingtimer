## 0.13.2

- Left-drag the minimap icon around the minimap edge; its angle is saved between sessions.
- Respects minimap scale, and stops cursor tracking when released or hidden.
- Releasing a drag does not open settings; a normal click still does.

Use `/reload`, then drag the round icon to your preferred position.

## 0.13.1

- Replaced the square minimap spell button with a small round, gold-rimmed icon.
- Positions the button on the minimap’s outer edge using its actual size, instead of covering the map with fixed offsets.
- Keeps the existing click-to-open settings and visibility switch.

Use `/reload` to apply the minimap styling fix.

## 0.13.0

- Organized the unchanged 400 × 56 bar into range/ammo, combat reminders, pet, and lock blocks with subtle dividers.
- Mark icon sits above the angle in the combat block; pet health stays attached to its portrait.
- Blocks remain stable when warnings appear or disappear, avoiding text/portrait movement during combat.
- Disabling a block returns its space to the range block. Long range text scales within its own slot instead of overlapping ammo or icons.
- Existing feature toggles, position, scale, and fading are preserved.

Use `/reload` to apply the layout.

## 0.12.1

- Settings window is draggable by default using its title or background, without unlocking the hunter bar.
- Reopening settings retains its position during the session. Closing while dragging stops movement cleanly.

Use `/reload` to apply the update.

## 0.12.0

- Added an upper-right minimap button that opens Hunter’s Friend settings, even when the bar is disabled.
- Added a small padlock on the bar to toggle movement. Green means unlocked; tooltips explain the action.
- Added separate visibility switches for both buttons and arranged settings into two columns.
- Locking retains normal fading and live updates; the bar remains 400 × 56.

Use `/reload` to enable the new buttons.

## 0.11.0

- Replaced Hunter’s Mark wording with the learned spell’s icon and a bright gold border when missing.
- Added independent toggles for range, ammo count, low-ammo warnings, pet-health highlight, Mark reminder, and idle fading, alongside existing portrait/angle controls.
- Mark reminder and angle can now display together without enlarging the bar.
- Existing settings are preserved; new feature switches default on.

Use `/reload`, then `/fhunter` to choose features. Pet-health highlighting requires the portrait display.

## 0.10.0

- Added an orange “Hunter's Mark!” reminder for unmarked living enemy targets.
- Learns the spell from your spellbook instead of assuming a Classic spell ID.
- Any hunter’s mark clears the reminder; aura changes update it immediately.
- Stays quiet for friendly/dead targets, unlearned spells, and unavailable or restricted aura readings.
- Uses the secondary angle area while missing, keeping the compact bar and ammo readable.

Use `/reload` to apply the update.

## 0.9.0

- Highlights the target-of-target portrait with a red border when it shows your own pet at 30% health or below.
- Updates immediately on pet health changes and clears after healing, pet replacement, or target changes.
- Dead pets, other players’ pets, and restricted health readings do not trigger the reminder.
- Visual Mend Pet reminder only; no automatic spell casting.

Use `/reload` to apply the update.

## 0.8.2

- Unlocking the bar no longer forces full opacity; dragging keeps the same visibility and updates as locked mode.
- Full opacity in combat, 60% with a target outside combat, and 20% without a target outside combat.
- Combat events update visibility immediately, without adding idle polling.

Use `/reload` to apply the fix.

## 0.8.1

- Friendly targets without a distance reading show only “Friendly target”.
- Kept the main range text on one line so it cannot crowd the ammo line.
- Reclaimed the right-hand text space whenever the target-of-target portrait is absent.

Use `/reload` to apply the layout fix.

## 0.8.0

- Ammo turns red at 200 or fewer arrows/bullets.
- Shows a one-time low-ammo warning at the threshold, including if enabled with ammo already low.
- Does not repeat after each shot or target change; restocking above 200 rearms it.
- Unavailable readings do not reset the warning or create a false alert.

Use `/reload` to apply the update.

## 0.7.1

- Raised the ammo and angle line by 6 pixels, bringing it closer to the range text and away from the bottom edge.
- Keeps the original bar size and saved position.

Use `/reload` to apply the spacing adjustment.

## 0.7.0

- Rebranded as Forever - Hunter's Friend, focused exclusively on hunters.
- Removed the runtime module registry and toolbox selector; /fhunter opens one settings panel.
- Moved ammunition directly below the main white range text, with optional angle alongside it.
- Migrates existing flat or toolbox distance settings once into dedicated hunter settings.
- Non-hunter characters do not create the bar. /futils remains a compatibility alias.
- Kept the existing addon folder and saved-variable name for seamless upgrades.

Use `/reload`, then `/fhunter` for settings.

## 0.6.0

- Added a small ammo count near the right side of the compact bar, beside the portrait.
- Counts carried ammunition of the selected type, excluding bank storage.
- Inventory events refresh the count even without a target, without adding idle polling.
- Empty hunter ammo slots show a red zero; missing or restricted data clears the reading.

Use `/reload` to apply the update. The bar remains 400 × 56.

## 0.5.2

- Replaced target-of-target wording with a portrait on the right, opposite the weapon icon.
- Kept the compact bar and reclaimed central space for distance.
- Optional facing angle is now signed degrees only; unavailable readings are hidden.
- Portraits clear on target loss or API failure and refresh when the target’s target changes.

Use `/reload` to apply the update.

## 0.5.1

- Restored the original 400 × 56 distance bar footprint.
- Moved target-of-target (ToT) and angle into two compact lines on the right instead of adding rows below.
- Distance text uses the left column; disabling both context lines gives it the full available width.
- Preserves your position, scale, and feature settings.

Use `/reload` to apply the compact layout.

## 0.5.0

- Distance Checker now shows your target’s current target, with YOU when it targets you.
- Added a live horizontal facing angle: straight ahead, left/right degrees, or behind.
- Unavailable or restricted position/facing data displays “Angle unavailable”; no attack eligibility is inferred.
- Both new rows have independent toggles in the Distance Checker settings, and the indicator resizes to fit.
- Target changes, target loss, and unavailable data clear stale context. Disabled modules retain no update loop or event listeners.

Use `/reload`, then `/futils` to configure the rows. Angle readings depend on client data availability, particularly for enemies. Automated checks use mocked APIs; live gameplay validation is still needed.

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
