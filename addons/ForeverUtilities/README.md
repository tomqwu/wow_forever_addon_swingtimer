# Forever Utilities

**See your range at a glance. Keep your screen clear between targets.**

Forever Utilities brings a clear, movable distance indicator to **World of Warcraft:
Forever**. Select an enemy to see an approximate yard bracket and a color-coded
icon. Clear your target and the panel dims to 20% opacity, staying out of the way
until you need it again.

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
brackets**, not exact measurements. Precision depends on learned abilities,
target combat reach, and client restrictions. Being in range does not guarantee
line of sight, facing, ammunition, or ability readiness.

## Get started

Install the `ForeverUtilities` folder into `_classic_beta_/Interface/AddOns/`,
restart WoW for first discovery, and enable **Forever Utilities**. Select a living
hostile target to begin. For later updates, use `/reload`.

| Command | Action |
| --- | --- |
| `/futils unlock` | Drag the indicator; stays fully visible while unlocked |
| `/futils lock` | Lock its position |
| `/futils scale 1.2` | Make it larger (supported range: 0.5–2) |
| `/futils on` / `/futils off` | Show or disable the indicator |
| `/futils reset` | Restore this addon's defaults |
| `/futils status` | Show version and range diagnostics |

**Upgrading from the old project?** Disable or remove ForeverSwing and the
ForeverHunterRange prototype to avoid duplicate UI. This project is now Forever
Utilities; the swing bar is no longer included. Older saved settings are untouched.

Designed for the **Forever 1.60.1 beta client**. Automated tests cover range logic,
UI behavior, and publishing; live gameplay validation remains ongoing. Report
issues with your client build and `/futils status` output.

[Source code](https://github.com/tomqwu/wow_forever_utilities) ·
[Report an issue](https://github.com/tomqwu/wow_forever_utilities/issues)
