# Decision Log

## D-001: Desktop engine

**Status:** accepted
**Decision:** Use Godot 4 with typed GDScript.
**Reason:** strong 2D workflow, open-source licensing and native Windows/macOS
exports without binding the project to a browser runtime.

## D-002: World model

**Status:** accepted
**Decision:** Generate one large detailed region from a campaign seed and persist
the generated facts.
**Reason:** each campaign should surprise the player while remaining coherent
and stable after creation.

## D-003: Narrative

**Status:** accepted
**Decision:** Use procedural narrative built from authored, validated modules.
**Reason:** supports indefinite varied campaigns while protecting tone and
quality. Runtime cloud AI is not required.

## D-004: Combat

**Status:** accepted
**Decision:** Turn-based combat uses alternating initiative on a visually hidden
isometric square grid and occurs in the exploration scene.
**Reason:** preserves tactical D&D-like rules while reducing inactive wait time.

## D-005: Player party

**Status:** accepted
**Decision:** The player directly controls one hero. Temporary companions are
autonomous and receive general tactical orders.
**Reason:** protects the solitary-hero identity without excluding relationships,
summons, animals or temporary allies.

## D-006: Persistence and defeat

**Status:** accepted
**Decision:** The world advances only while playing and never resets on hero
defeat. Death saves precede return to the latest refuge and persistent
consequences.
**Reason:** defeat matters without deleting a long campaign.

## D-007: Progression

**Status:** accepted
**Decision:** Levels 1-20, controlled multiclassing, then horizontal progression,
limited epic talents and optional legacy.
**Reason:** maintain recognizable rules and allow indefinite play without
unbounded numerical inflation.

## D-008: Intellectual property

**Status:** accepted
**Decision:** Use legally permitted SRD 5.2.1 material and original world
content.
**Reason:** the game needs its own identity and a distributable legal basis.

## D-009: Survival

**Status:** accepted
**Decision:** Survival systems are consequential but increasingly automated by
refuge upgrades and specialists.
**Reason:** preparation should create decisions, not repetitive chores.

## D-010: Localization

**Status:** accepted
**Decision:** Portuguese and English are architectural requirements from the
first milestone.
**Reason:** procedural grammar and UI cannot be safely retrofitted late.

## D-011: Tactical production order

**Status:** accepted
**Decision:** Complete modular scenery before character animation, then continue
with elemental combat, AI behavior, complete rules, combat saves and exploration.
Each area is delivered through small reviewed steps.
**Reason:** the current mechanics are readable, but the environment is the
largest gap between the prototype and the approved visual promise.
