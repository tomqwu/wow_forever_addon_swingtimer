# Hunter helper priorities — researched 2026-09-19

These are recommendations, not implemented features. Keep them optional, compact,
and aware of learned abilities/talents. Do not assume Classic numbers apply.

1. **Pet-care status:** extend the existing 30% Mend Pet highlight so it works independently of the target-of-target portrait. Show missing/dead pet status when relevant, and distinguish an active Mend Pet effect from a request to cast it. Suppress missing-pet warnings for deliberate petless play.
2. **Happiness and feeding:** small mood icon and an out-of-combat feeding reminder. The verified Forever client documents GetPetHappiness and GetPetFoodTypes. Confirm live values and feeding behavior before implementation; avoid fixed damage multipliers from old guides.
3. **Aspect reminder:** show the active aspect and warn when none is present in combat. Let players choose a preferred aspect rather than declaring one correct for every hunter build.
4. **Growl/autocast reminder:** opt-in group warning if Growl is on, and solo warning if it is off. The client's PetActionBar reads GetPetActionInfo including autoCastAllowed and autoCastEnabled. Never toggle it automatically or assume every group wants it off.
5. **Threat warning:** alert when the enemy switches from the pet to the player; supplement with readable threat state where available. UnitDetailedThreatSituation and UnitThreatSituation can return restricted values. Never invent threat percentages.
6. **Selected cooldowns:** optional small readiness icons for learned defensive/trap abilities. Discover current spells/cooldowns rather than copying old rotation timings.

Keep the existing range/mark/ammo reminders. Add pet-care first, then aspects and
Growl. Avoid a large rotation advisor: Forever tuning and builds are still changing.

## Evidence

- [Blizzard Forever deep-dive recap](https://worldofwarcraft.blizzard.com/en-us/news/24303313): tactical combat, crowd control, threat, and revised talents remain central. This supports prioritizing utility awareness rather than a fixed rotation.
- [Forever client PetInfo documentation](https://github.com/Gethe/wow-ui-source/blob/4d5d706b8e01c5ebe01c8dd9b7a07151d8d37069/Interface/AddOns/Blizzard_APIDocumentationGenerated/PetInfoDocumentation.lua): happiness and food APIs, verified in the local source mirror.
- [Client pet action bar](https://github.com/Gethe/wow-ui-source/blob/4d5d706b8e01c5ebe01c8dd9b7a07151d8d37069/Interface/AddOns/Blizzard_ActionBar/Shared/PetActionBar.lua): autocast state access.
- [Client unit API documentation](https://github.com/Gethe/wow-ui-source/blob/4d5d706b8e01c5ebe01c8dd9b7a07151d8d37069/Interface/AddOns/Blizzard_APIDocumentationGenerated/UnitDocumentation.lua): health, unit identity, and restricted threat values.

API declarations establish possible implementation paths, not proof every value
is available in every live situation. Validate against the user's beta client.
