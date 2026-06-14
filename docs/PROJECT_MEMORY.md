# Project Memory

## Purpose

This file is the persistent memory for D&D 8Bits. Read it before planning or
implementing work. Update it when the owner approves a product decision.

## Product identity

- Desktop single-player RPG for Windows and macOS.
- Godot 4 is the chosen engine.
- Isometric presentation with modern pixel art.
- Portuguese and English from the beginning.
- Direct-download distribution for the initial release.
- Intended content rating: 14.
- The experience teaches tabletop-RPG concepts naturally over a long campaign.

## Non-negotiable vision

- One directly controlled hero, fully created by the player.
- Mostly solo play; temporary companions are AI-controlled through general orders.
- Open world generated from a seed for every campaign.
- The generated world remains persistent after creation and changes only while
  the game is running.
- Procedural history, cultures, geography, factions, NPC lives, quests, bosses,
  rumors, economy and narrative.
- Turn-based combat on a visually disguised isometric grid, directly in the
  exploration scene.
- Rules remain close to D&D 5e/2024 and legally usable SRD 5.2.1 material.
- The game continues indefinitely after major objectives and level 20.
- Death saving throws occur at 0 HP. Defeat returns the hero to the latest
  refuge and leaves persistent consequences.
- The player chooses a mobile refuge form during the campaign and can improve it.

## Player agency

The game must support multiple valid lives: hero, explorer, scholar, merchant,
religious champion, faction leader, treasure seeker, criminal or a mixture.
There is no mandatory final objective.

Alignment is descriptive and changes from observed actions. Reputation is
independent for settlements and factions. Rumors may be false, stale or
manipulated.

## Scope discipline

The complete vision is intentionally large. Build it through vertical slices:

1. prove a small but complete adventure loop;
2. make every system deterministic and saveable;
3. expand content only after its supporting simulation is stable;
4. never replace authored quality with uncontrolled random generation;
5. procedural narrative uses authored grammar, constraints and validation.

## Documentation rule

Before changing product behavior:

1. check `GAME_DESIGN.md`;
2. record a new decision in `DECISIONS.md` if needed;
3. update `TECHNICAL_SPEC.md` when contracts or architecture change;
4. update `ROADMAP.md` when scope or ordering changes.

## Legal rule

Use only material permitted by SRD 5.2.1 and its license, with required
attribution. Names, lore, cultures, divinities, art, writing and mechanics
outside that permission must be original. See `LEGAL.md`.

## Current implementation state

Tactical visual slice build 0.4.0:

- Godot project structure;
- desktop title screen;
- Portuguese/English toggle;
- deterministic campaign seed service;
- serializable simulation clock skeleton;
- campaign session autoload;
- logical isometric grid and obstacle cells;
- directly controlled level-1 Fighter;
- deterministic d20 attacks, armor class, damage and critical hits;
- alternating hero/enemy team turns;
- keyboard, mouse and basic controller input;
- visible combat roll log;
- terrain elevation and high-ground attack bonus;
- cover-based armor class bonus and line-of-sight blockers;
- fire and water surface representation, with fire entry damage;
- ranged enemy attacks;
- attacks of opportunity using reactions;
- tactical camera zoom;
- improved HUD framing and original art-direction reference;
- original transparent pixel-art hero and raider sprites;
- sprite shadows, team rings, selection ring and unit labels;
- moonlit ruin silhouettes, torch glows and vignette treatment;
- asset provenance records and generated-source traceability;
- modular terrain catalog separated from combat rules;
- stone, cracked-stone and water terrain modules;
- elevation rendered with distinct isometric side faces;
- deterministic combat unit test and tactical scene smoke test;
- archived browser prototype.

Godot 4.6.3 imports and runs the project successfully. The tactical scene was
also rendered and visually inspected at 1280x720.
