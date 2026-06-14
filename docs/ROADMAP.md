# Implementation Roadmap

The roadmap favors complete playable slices over broad unfinished systems.
Dates are deliberately absent until team size and art capacity are known.

## Milestone 0: Foundation

Goal: reproducible desktop project and documented product.

- [x] project memory and specifications;
- [x] Godot project skeleton;
- [x] campaign seed identity;
- [x] bilingual startup shell;
- [x] simulation clock skeleton;
- [x] install Godot and validate imports;
- [x] automated GDScript tests;
- [ ] Windows development export;
- [ ] macOS export configuration;
- [ ] CI validation.

Exit: a clean checkout opens and exports on both target platforms.

## Milestone 1: Tactical sandbox

Goal: one polished isometric encounter proving the core rules.

- [x] logical isometric grid foundation;
- [x] keyboard, mouse and basic controller navigation;
- [x] one hero with Fighter level 1 combat statistics;
- [x] alternating team initiative;
- [x] movement, attack action and visible d20 records;
- [x] camera zoom;
- [ ] camera movement;
- [x] reactions and opportunity attacks;
- [x] height and cover foundation;
- [x] first original character sprite pass;
- [x] first atmospheric ruin and lighting pass;
- [ ] directional sprite poses and combat animations;
- [ ] modular authored terrain tiles and props;
- [x] modular terrain catalog foundation;
- [x] stone, cracked-stone and water tile modules;
- [x] proper isometric elevation side faces;
- fire, water and electricity surfaces;
- one autonomous companion with general orders;
- enemy morale, surrender and flight;
- save/load inside combat.

Exit: a 20-minute encounter is enjoyable and understandable to a beginner.

### Current production order

1. modular scenery;
2. character animation;
3. elemental combat;
4. AI behavior;
5. complete combat rules;
6. save/load during combat;
7. first exploration slice.

### Modular scenery steps

- [x] Step 1: terrain catalog, stone, cracked stone, water and elevation sides;
- [ ] Step 2: map borders, walls and ruined wall variants;
- [ ] Step 3: columns, barricades and destructible props;
- [ ] Step 4: moss, vegetation, rubble and environmental dressing;
- [ ] Step 5: lighting integration, particles and final readability pass.

## Milestone 2: Exploration slice

Goal: connect combat to a small persistent region.

- continuous exploration and travel map;
- stealth perception: sight, light, noise and tracks;
- climbing, swimming and jumping;
- day/night, weather, fatigue and rests;
- inventory weight plus slots;
- camp and first mobile-refuge upgrade;
- one settlement, wilderness and dungeon;
- traps and out-of-combat abilities.

Exit: a 60-90 minute adventure supports multiple approaches.

## Milestone 3: Generated campaign prototype

Goal: prove coherent procedural generation.

- terrain, climate, resources and routes;
- generated ancient history;
- original cultures, divinities and factions;
- settlements and notable NPCs;
- authored procedural quest grammar;
- rumors with provenance and uncertainty;
- faction simulation and regional economy;
- golden-seed regression suite.

Exit: ten seeds produce distinct, coherent and completable regional arcs.

## Milestone 4: Living-world vertical slice

Goal: prove persistent consequences across several in-game months.

- NPC aging, families, careers and mortality;
- war, alliances, conquest and faction collapse;
- settlement damage, rebuilding and founding;
- crime, law, prison and bounties;
- business/property ownership;
- relationships, romance, rivalries and reputation;
- codex and knowledge discovery.

Exit: distant events remain coherent, performant and legible to the player.

## Milestone 5: Character breadth

Goal: expand from the proven core without lowering quality.

- all twelve SRD classes;
- SRD species and approved original species;
- backgrounds, subclasses and original divinities;
- multiclass rules and balance validation;
- levels 1-20;
- crafting professions and constrained experimentation;
- mounts, flight, vessels and navigation.

Content ships incrementally behind complete tests rather than all at once.

## Milestone 6: Long campaign and legacy

- procedural major objectives;
- indefinite post-objective play;
- epic horizontal progression;
- voluntary descendant/apprentice/ally/unrelated legacy;
- procedural bosses and other planes;
- full mobile-refuge forms;
- mature economy and ownership loops.

## Milestone 7: Release

- complete Portuguese and English localization;
- accessibility audit;
- performance tiers and compatibility testing;
- content-rating review;
- Windows signing;
- macOS signing and notarization;
- direct-download installer, update and rollback process.
