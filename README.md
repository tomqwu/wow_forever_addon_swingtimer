# ForeverSwing

A lightweight melee swing timer for **World of Warcraft: Forever beta 1.60.1 (69893)**.
Uses the native `PLAYER_SWING` event rather than combat-log parsing.

- Main-hand countdown and optional off-hand bar
- Movable, resizable frame with saved settings
- Out-of-range dimming, a 0.4-second reference line and shaded end-of-swing area
- Guards unavailable APIs and restricted values
- No external addon dependencies

## Install

Download this repository and copy the **ForeverSwing** folder into
`<World of Warcraft>/_classic_beta_/Interface/AddOns/`.
The final path must be `AddOns/ForeverSwing/ForeverSwing.toc`.
Restart WoW and enable **ForeverSwing** in the AddOns list.

Run `/fswing unlock` to position it, `/fswing lock` to lock it,
`/fswing test` for a preview, and `/fswing status` for diagnostics.
Attack a hostile target to test real swing events.

## Seal twisting

Forever's Twist of Light uses a seal echo on the next swing. This addon does not
assume the old 0.4-second timing window, detect successful twists, or automate
abilities. `/fswing cue 0.4` enables the reference marker (default for new installs); `/fswing cue 0` disables it.

[Full commands, API research, sources and limitations](ForeverSwing/README.md)

## Validation

Lua syntax checks and 39 model/mock-client checks pass. Live in-game combat,
dungeon and PvP validation is still pending.

Run from the repository root with Lua installed:

```sh
luac -p ForeverSwing/Core.lua
luac -p ForeverSwing/ForeverSwing.lua
lua tests/test_foreverswing.lua
```
