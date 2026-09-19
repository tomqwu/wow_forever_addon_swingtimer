# Forever - Hunter's Friend

<p align="center"><img src="assets/branding/hunters-friend-logo.png" width="256" alt="Hunter’s Friend — golden lynx and emerald bow"></p>

**Your range, ammunition, and target awareness in one compact hunter bar.**

Built for hunters in **World of Warcraft: Forever**, Hunter's Friend shows what
you need at a glance without a toolbox or module selector.

- **Range at a glance:** a colored weapon icon and readable range text.
- **Ammo below the range text:** a small count of your selected ammunition carried in bags, excluding banks. Inventory changes update it even without a target. At 200 or fewer, the count turns red and a one-time low-ammo warning appears. Restocking above 200 rearms the warning. An empty hunter ammo slot shows zero.
- **Target-of-target portrait:** a small portrait on the right shows who your target is targeting, without extra wording.
- **Hunter's Mark reminder:** a compact orange warning appears when your living enemy target has no readable Hunter's Mark debuff and you have learned the spell. It clears when marked, including by another hunter. Unavailable aura data stays quiet.
- **Mend Pet reminder:** the right-hand portrait gets a red border when it shows your own living pet at 30% health or below. The border clears when healed or the target changes. This is a visual reminder, not an automatic cast.
- **Optional facing angle:** signed degrees relative to your character: positive left, negative right, zero ahead. Hidden when valid position data is unavailable.
- **Compact and movable:** the bar stays 400 × 56, with adjustable scale and position.
- **Quiet while idle:** full opacity in combat, 60% with a target outside combat, and 20% without a target. Unlocking only enables dragging and keeps these visibility rules; disabled means no bar updates or event listeners.

## Range colors

| Color | Meaning |
| --- | --- |
| Green | In ranged auto-attack range |
| Amber | In melee range |
| Orange | Confirmed too close for ranged auto attack |
| Red | Beyond ranged attack range or checked spell range |
| Blue | Estimated distance available, attack-range status unavailable |
| Gray | No target or unavailable range data |

Readings such as `~8–35 yd` are approximate spell-based brackets. Decimal yards
appear only when the client supplies validated numeric distance. Restricted
readings are never guessed. Range and facing do not guarantee line of sight or
that an attack can fire. No combat actions are automated.

## Setup

Install the `ForeverUtilities` folder into `_classic_beta_/Interface/AddOns/`.
The folder name is retained for seamless upgrades; the addon appears in WoW as
**Forever - Hunter's Friend**. Restart for first installation, or use `/reload`
for updates. The bar runs only on hunter characters.

Open `/fhunter` for a single settings panel: enable the bar, lock its position,
change scale, or toggle the portrait and angle. `/futils` remains an alias.

| Command | Action |
| --- | --- |
| `/fhunter` | Open settings |
| `/fhunter unlock` / `lock` | Move or lock the bar |
| `/fhunter scale 1.2` | Adjust size (0.5–2) |
| `/fhunter on` / `off` | Enable or disable |
| `/fhunter reset` | Restore defaults |
| `/fhunter status` | Version and range diagnostics |

Existing Forever Utilities position, scale, and display settings migrate
automatically. This is a dedicated hunter addon; the modular toolbox and swing
bar are no longer included. No other addons are required.

Designed for the Forever 1.60.1 beta client. API availability may limit numeric
distance, angles, and ammo readings. Automated checks use mocked APIs; live
in-game validation remains ongoing.

[Source code](https://github.com/tomqwu/wow_forever_utilities) ·
[Report an issue](https://github.com/tomqwu/wow_forever_utilities/issues)

[Developer guide](docs/development.md) · [Release history](docs/changelog.md)
