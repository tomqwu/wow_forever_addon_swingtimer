# Compact hunter bar layout

The bar remains 400 × 56 UI pixels before the user's saved scale. These are
visual groups inside one hunter addon, not a return to the generic module system.

## Blocks, left to right

| Block | Default horizontal bounds | Contents |
| --- | --- | --- |
| Range / supplies | 6–270 | Weapon icon; white one-line range; ammo directly underneath |
| Combat | 270–326 | Highlighted Mark icon above signed facing angle |
| Pet | 326–374 | Target-of-target portrait; red health border only for own low-health pet |
| Control | 374–394 | Small lock button |

Six pixels remain as outer padding. Subtle dividers mark block boundaries.
Range text starts at x=66 and has 196 pixels with all blocks enabled. It uses
16px type when possible, scaling to 12px for long readings without wrapping.
Ammo stays 12px below it. Disabling range removes its icon and moves supplies
left. Disabling combat, portrait, or lock returns that width to range/supplies.

Blocks are allocated from preferences, not transient warning state. Applying
Hunter's Mark or changing targets never shifts other icons or text. Combat icons
stay separate from pet health. Existing fading and movement settings apply to the
whole bar, including its lock button.

## Future additions (design only)

- Pet care belongs in the pet block. Health danger should outrank missing-pet,
  revive, and feeding notices; do not draw several competing borders.
- Combat reminders can use up to two small icon slots in the combat block.
  Use a deterministic priority (urgent defensive state, required debuff, aspect).
  Secondary details belong in a tooltip or settings, not extra permanent rows.
- Ammo remains in supplies; low ammunition changes its emphasis rather than
  creating another text row.
- New features require individual switches and should not expand the outer bar.
- Do not claim future pet-care or cooldown tracking exists yet.

Layout.lua centralizes the allocation rules. Tests exercise all 32 combinations
of range, mark, angle, pet, and control settings for bounds and overlap. Live
in-game font appearance should still be checked after /reload.
