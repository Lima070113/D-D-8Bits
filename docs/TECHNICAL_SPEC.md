# Technical Specification

## 1. Technology

- Engine: Godot 4, stable release channel.
- Language: typed GDScript.
- Rendering: 2D isometric presentation with authored pixel-art assets.
- Platforms: Windows x86-64 and macOS Universal.
- Distribution: downloadable signed builds.
- Data: versioned Godot Resources and JSON-compatible save snapshots.

Godot was selected for its 2D workflow, open-source license, desktop exports and
small operational footprint.

## 2. Architecture

The project uses four directional layers:

1. `presentation`: scenes, UI, camera, animation and input.
2. `gameplay`: use cases such as movement, combat, dialogue and crafting.
3. `domain`: deterministic rules and immutable definitions.
4. `simulation`: world generation, time, NPCs, factions and economy.

Presentation may call gameplay services. Gameplay may call domain and
simulation. Domain code must not depend on scenes, nodes or rendering.

## 3. Directory layout

```text
src/
  presentation/
  gameplay/
  domain/
  simulation/
content/
  definitions/
  narrative/
  worldgen/
assets/
  art/
  audio/
localization/
tests/
docs/
archive/
```

## 4. Determinism

Every campaign owns:

- a human-readable seed;
- a stable numeric seed;
- a generation version;
- independent random streams per subsystem.

Subsystems must not share one mutable RNG. Adding an optional treasure roll must
not change geography or NPC ancestry. Streams derive from:

`campaign_seed + generation_version + subsystem_id + entity_id`

Simulation commands are deterministic given state and command inputs.

## 5. World generation pipeline

Generation runs as a staged job with validation after every stage:

1. campaign identity;
2. cosmology;
3. terrain and climate;
4. resources and routes;
5. historical timeline;
6. cultures, species and religions;
7. settlements and factions;
8. notable NPCs and families;
9. current conflicts;
10. quest and rumor seeds.

Generation output is stored. The game never regenerates canonical facts on load.

## 6. Simulation model

The simulation uses scheduled events rather than updating every entity each
frame. Event categories include births, deaths, travel, production, trade,
weather, war, construction, relationship changes and quest deadlines.

Simulation detail is selected by distance and narrative importance. Promotion
from aggregate to detailed simulation must preserve identity and prior facts.

## 7. Isometric grid

Logical coordinates use integer square-grid cells. Rendering converts them to
isometric screen coordinates. Pathfinding, range, cover and effects operate on
logical coordinates, never pixel positions.

Required cell data:

- walkability and movement cost;
- floor elevation;
- occupancy;
- cover edges;
- material and wetness;
- hazards and surfaces;
- visibility blockers;
- destructible references.

## 8. Combat state machine

Combat phases:

1. detection and encounter intent;
2. initiative-group construction;
3. alternating activation;
4. action resolution;
5. reactions;
6. environmental resolution;
7. morale and objective evaluation;
8. round-end effects;
9. victory, retreat, surrender, capture or transition.

Every action produces a structured roll record suitable for UI explanation,
replay diagnostics and save-in-combat support.

## 9. AI

Companion AI follows player-issued policies such as aggressive, defensive,
support, conserve resources and avoid collateral damage.

Decision scoring considers goals, personality, known information, risk,
relationships and orders. AI cannot read hidden world state.

## 10. Save format

Saves include:

- schema and generation versions;
- world facts and generated content IDs;
- simulation clock and event queue;
- hero, inventory, relationships and reputation;
- NPC/faction/settlement changes;
- combat snapshot when applicable;
- accessibility and control settings.

Saves use atomic replacement and maintain rolling backups. Migrations are
required for every released schema change.

## 11. Localization

No player-facing text is hard-coded after the foundation phase. Content stores
localization keys. Procedural text uses grammar-aware templates per language;
English word order is never reused blindly for Portuguese.

## 12. Performance budgets

Initial targets on recommended hardware:

- 60 FPS presentation during exploration and combat;
- less than 100 ms simulation work per visible turn;
- background simulation spread across frames;
- initial world generation reports progress and remains cancellable;
- no full-world NPC iteration per frame.

Precise hardware tiers will be defined after the vertical slice.

## 13. Testing

- Unit tests: dice, modifiers, conditions, calendar, seed derivation.
- Property tests: generation invariants and save round trips.
- Golden-seed tests: known worlds remain stable per generation version.
- Scenario tests: combat, economy and faction chains.
- Manual checks: controller navigation, localization overflow and exports.

## 14. Build and release

CI will eventually:

1. validate formatting and tests;
2. import the Godot project headlessly;
3. build Windows and macOS artifacts;
4. generate checksums and release notes.

macOS distribution requires signing and notarization credentials. Windows
signing is strongly recommended before public distribution.

## 15. Current foundation

Implemented:

- project configuration;
- startup scene;
- basic bilingual title screen;
- campaign seed service;
- serializable simulation clock.
- persistent campaign session;
- isolated tactical unit and combat encounter domain models;
- logical isometric arena renderer;
- alternating team turns and deterministic d20 action records;
- keyboard, mouse and controller-ready input actions;
- headless combat and scene smoke tests.
- battlefield model for elevation, cover, blocking and elemental surfaces;
- line-of-sight and ranged attack rules;
- reaction attacks triggered by leaving melee reach;
- presentation zoom independent from logical grid coordinates.
- transparent character texture rendering with geometry fallback retained by
  the domain-independent presentation layer;
- project-local asset provenance documentation.
- terrain type is persistent cell data, separate from temporary surfaces;
- presentation resolves terrain through a modular visual catalog;

Validated with Godot 4.6.3:

- project import;
- GDScript parser and global class registration;
- generation of `.translation` resources from `ui.csv`.

Still pending:

- Windows and macOS export presets.
