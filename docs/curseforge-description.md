# Forever Utilities

Forever Utilities for WoW Forever: target distance checks with color-coded range indicators.

A lightweight utilities addon for World of Warcraft: Forever. The first utility
is a target distance checker. There is no swing bar.

## Distance checker

Select a living hostile target to see an approximate yard bracket and an icon
that changes color as range changes:

- Green: in ranged auto-attack range.
- Amber: in melee range.
- Orange: confirmed too close for ranged auto attack.
- Red: confirmed beyond ranged auto-attack range.
- Gray: ambiguous or unavailable status, or no valid target.

Labels such as <=5 yd or ~8–35 yd are spell-based brackets, not exact distance.
Precision depends on learned abilities, target combat reach, and client API
restrictions. The range checker works across classes; hunter shooting-range
boundaries are especially useful. Range does not guarantee line of sight,
facing, ammo, or ability readiness.

## Commands

- `/futils unlock` — drag the icon; `/futils lock` — lock it.
- `/futils on` and `/futils off` — toggle the checker.
- `/futils scale 1.2` — resize the indicator.
- `/futils reset` — reset the addon's settings.
- `/futils status` — show the version.

## Updating from the former swing timer

This project is now Forever Utilities. Remove or disable ForeverSwing and the
ForeverHunterRange prototype to avoid old or duplicate UI. Enable **Forever
Utilities** and restart WoW for first discovery. Existing saved settings for the
older addons are left untouched. Future utilities updates can use `/reload`.

Designed for the Forever 1.60.1 beta client. Automated checks use a simulated
client; live gameplay validation is still pending. Please report the client
build and any errors when submitting an issue.

Source and issues: https://github.com/tomqwu/wow_forever_addon_swingtimer

The distance readout uses a dark panel, large outlined white text, and a larger
icon with a solid range-colored border for visibility against terrain. Use
`/futils scale 1.2` to enlarge it further; existing position and scale are preserved.
