# ForeverSwing 0.1.0

A small, standalone melee swing-bar addon for World of Warcraft: Forever beta
1.60.1 (69893). Main-hand countdown, optional off-hand countdown, movable frame,
saved layout, range dimming, and an optional personal timing marker.

## Use

Install the `ForeverSwing` folder under:
`<World of Warcraft>\_classic_beta_\Interface\AddOns\ForeverSwing`

Fully restart WoW after the first installation so the new addon is discovered.
Enable ForeverSwing in the character-selection AddOns list. The bar initially
says “Waiting for swing”; attack a hostile target to start the native timer.
The bar fills left to right while the number counts down. A completed timer
returns to Ready; it does not pretend another swing happened.

- `/fswing unlock` — drag the bar.
- `/fswing lock` — lock the position and let mouse clicks pass through.
- `/fswing test` — one explicitly labeled demo cycle, replaced by real swings.
- `/fswing offhand on` or `off` — second melee bar (off by default for Paladin).
- `/fswing width 350` — width from 120 to 800.
- `/fswing scale 1.2` — scale from 0.5 to 2.
- `/fswing cue 0.4` — optional marker/highlight in the final 0.4 seconds.
- `/fswing cue 0` — disable the cue (default).
- `/fswing reset` — restore addon settings.
- `/fswing status` — client build/interface, event availability and received count.

The optional cue is YOUR timing preference, not a confirmed Forever seal-twist
window. This addon does not detect equipped seals, Echo consumption, successful
twists, the global cooldown, or recommend/cast abilities. It supports melee
main-hand and off-hand swings, not ranged auto shots.

## Research: Forever is different

The installed `.build.info` identifies 1.60.1.69893. The source mirror's `forever`
branch at commit `4d5d706b8e01c5ebe01c8dd9b7a07151d8d37069` is labeled with the same
build. Primary-source API and UI files:

- [SwingTimerDocumentation.lua](https://github.com/Gethe/wow-ui-source/blob/4d5d706b8e01c5ebe01c8dd9b7a07151d8d37069/Interface/AddOns/Blizzard_APIDocumentationGenerated/SwingTimerDocumentation.lua)
- [Blizzard_SwingTimer.lua](https://github.com/Gethe/wow-ui-source/blob/4d5d706b8e01c5ebe01c8dd9b7a07151d8d37069/Interface/AddOns/Blizzard_SwingTimer/Blizzard_SwingTimer.lua)
- [Blizzard_SwingTimer.xml](https://github.com/Gethe/wow-ui-source/blob/4d5d706b8e01c5ebe01c8dd9b7a07151d8d37069/Interface/AddOns/Blizzard_SwingTimer/Blizzard_SwingTimer.xml)
- [Blizzard's Forever Deep Dive](https://worldofwarcraft.blizzard.com/en-us/news/24303313)

Findings:

1. `PLAYER_SWING` carries `(swingDuration, swingType)`.
2. `Enum.PlayerSwingType` identifies MainHand=0, OffHand=1, Ranged=2.
3. Blizzard's own bar starts a duration at `GetTime() + swingDuration` and does
   not synthesize another swing when the duration expires. This addon follows
   that timing model. It does not infer swings from combat-log damage.
4. `C_SwingTimer.IsTargetWithinSwingRange` returns a nullable boolean. Nil is
   unknown, not out of range. The addon polls this at most roughly 7 times per
   second while a timer runs, rather than changing the shared range subscription.
5. The native frame also exposes the `showSwingTimer` CVar. To try Blizzard's
   built-in alternative, use `/console showSwingTimer 1` and configure the bars
   in Edit Mode. This addon does not change that CVar or hide Blizzard's bars.
6. Blizzard describes Twist of Light as carrying a seal echo into the next
   melee swing. The old Classic/TBC 0.4-second timing rule is not assumed here.
7. Documentation presence does not prove third-party accessibility in every
   combat restriction scope. Registration is guarded, secret values are not
   compared or used in arithmetic, and restricted data clears the timers.

## Validation and limits

- `luac -p` syntax validation passed for both Lua files.
- 37 local model/mock-client checks passed. They cover countdown math,
  invalid/secret payloads, ranged exclusion, main/off-hand separation,
  range semantics, expiry without free-running, equipment changes, demo
  replacement, saved-setting validation, and blocked event registration.
- Not yet tested in the live Forever game UI, combat, dungeons or PvP.
- Interface tag is 16001, corresponding to 1.60.1. `/fswing status` prints the
  actual runtime interface number for verification if beta packaging changes.
- Like the native bar, timing is based on event receipt. There is no independent
  latency compensation, parry-haste inference, extra-attack classification, or
  recalculation from UNIT_ATTACK_SPEED. Those changes depend on native events.
- Reloading during a swing cannot reconstruct its start; wait for the next event.
- API failure produces an unavailable/restricted state rather than an estimated
  combat timer. A future client with secret duration objects would need a new
  supported display path; this version does not try to bypass restrictions.

## In-game acceptance check

1. Restart WoW, enable addon, run `/fswing status` and `/fswing test`.
2. Attack a target. The event count should increase and the countdown should
   restart from native melee events. Demo alone is not a combat validation.
3. Compare with Blizzard's bar (`/console showSwingTimer 1`).
4. Test stop/start attacking, range changes, weapon swaps, and attack-speed buffs.
5. With Twist of Light learned, compare the bar against actual swings; validate
   seal/Echo behavior separately. No successful-twist claim is made by this UI.
6. Repeat inside an instance/PvP if those modes matter. If timing becomes
   restricted, record `/fswing status` and any Lua error; do not assume accuracy.

To remove, disable ForeverSwing in the AddOns list or remove only its folder
while WoW is closed. No Blizzard UI files, other addons or game settings change.
