# Forever Utilities

**Your utilities, your choice. Keep the tools you need and switch off the rest.**

Forever Utilities is a modular toolbox for **World of Warcraft: Forever**.
Open `/futils` to choose which utilities are enabled and adjust each one's settings.
**Distance Checker** is the first included utility; future tools will have their
own controls rather than being added to the distance indicator.

## Choose your utilities

- **One toolbox panel:** open `/futils` (or `/futils options`).
- **Independent toggles:** enable only the features you want.
- **Per-utility settings:** changes and resets stay scoped to the selected utility.
- **No disabled-module work:** disabled utilities stop their event listeners and update loops.
- **Settings preserved:** existing distance position, scale, and enabled state migrate automatically.

Select **Distance checker** in the panel to enable it, lock or unlock its position,
change its size, or reset its settings. Uncheck “Lock indicator position” to drag
it on your screen. The Close button or Escape dismisses the toolbox.

## Distance Checker

Select an enemy to see a live yard reading when available, or an approximate
range bracket and color-coded icon. Clear your target and the panel dims to 20%
opacity. Friendly targets without a usable reading say “Friendly target — Distance
unavailable.” Numeric readings depend on what the client makes available.

A portrait on the **right** shows your target’s current target, opposite the weapon
icon on the left. It disappears when no target-of-target portrait is available.
There is no target-of-target wording. The optional angle reading shows signed
degrees only: positive means left, negative means right, and zero means ahead.
It follows character facing, not the camera, and hides when position/facing data
is unavailable. Both features can be toggled in `/futils`. The bar stays 400 × 56.
Angle is a direction measurement, not proof that an attack can hit.

A small **Ammo: 123** reading beside the portrait counts your selected ammo type
in carried inventory, excluding bank storage. It refreshes on inventory changes
even without a target. Hunters with an empty ammo slot see a red **Ammo: 0**;
unavailable readings and empty slots for other classes are hidden.

## Built for quick reads

- **Readable during combat:** large outlined text, a dark background, and a bright colored icon border.
- **Quiet with no target:** 20% opacity while idle, full visibility when targeting or repositioning.
- **Your layout:** drag it anywhere, resize it, or turn it off with simple commands.
- **Useful across classes:** distance brackets follow your learned spells, with Auto Shot checks for hunters.
- **Standalone:** no required addons, no swing bar, and no automated combat actions.

## Understand the colors

| Color | Meaning |
| --- | --- |
| Green | In ranged auto-attack range |
| Amber | In melee range |
| Orange | Confirmed too close for ranged auto attack |
| Red | Beyond ranged attack range or beyond the checked spell range |
| Blue | A distance bracket is available, but attack-range status is not |
| Gray | No target, invalid target, or range data unavailable |

Readings such as `<=5 yd`, `~8–35 yd`, and `>100 yd` are **approximate spell-based
brackets**, not exact measurements. A decimal reading such as `23.4 yd` is shown
only when the client supplies a validated numeric distance. It refreshes every
0.15 seconds and may be unavailable for enemies or in restricted content. Numeric
position distance can differ from spell reach, so colors still follow attack checks. Precision depends on learned abilities,
target combat reach, and client restrictions. Being in range does not guarantee
line of sight, facing, ammunition, or ability readiness.

## Get started

Install the `ForeverUtilities` folder into `_classic_beta_/Interface/AddOns/`,
restart WoW for first discovery, and enable **Forever Utilities**. Open `/futils`
to choose your utilities, then select a target to try Distance Checker. For later updates, use `/reload`.

| Command | Action |
| --- | --- |
| `/futils` | Open the shared utilities panel |
| `/futils unlock` | Drag the indicator; stays fully visible while unlocked |
| `/futils lock` | Lock its position |
| `/futils scale 1.2` | Make it larger (supported range: 0.5–2) |
| `/futils on` / `/futils off` | Show or disable the indicator |
| `/futils reset` | Restore Distance Checker defaults only |
| `/futils status` | Show version and range diagnostics |

**Upgrading from the old project?** Disable or remove ForeverSwing and the
ForeverHunterRange prototype to avoid duplicate UI. This project is now Forever
Utilities; the swing bar is no longer included. Older saved settings are untouched.

Designed for the **Forever 1.60.1 beta client**. Automated tests cover range logic,
UI behavior, and publishing; live gameplay validation remains ongoing. Report
issues with your client build and `/futils status` output.

[Source code](https://github.com/tomqwu/wow_forever_utilities) ·
[Report an issue](https://github.com/tomqwu/wow_forever_utilities/issues)

[Developer guide](docs/development.md) · [Release history](docs/changelog.md)
