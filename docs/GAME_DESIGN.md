# Game Design Specification

## 1. High concept

D&D 8Bits is a single-player isometric fantasy RPG in which every campaign
creates a persistent world with its own ancient history, civilizations,
divinities, geography and conflicts. The player builds one hero and decides what
their life means instead of following one mandatory destiny.

The emotional target is wonder, attachment and consequence. Heroic adventure
and dark fantasy alternate according to region, history and player action.

## 2. Design pillars

### A living generated world

Generation creates causes, not disconnected decorations. Geography shapes
trade; trade shapes settlements; history shapes cultures; cultures shape
factions, religion, conflict, quests and prices.

### Faithful tactical role-playing

Combat and character rules stay close to D&D 5e/2024 through legally usable SRD
5.2.1 content. Rolls and modifiers are visible so an inexperienced player learns
why outcomes occur.

### One hero, many lives

The player controls one hero directly. Play styles include adventuring,
crafting, trade, politics, crime, scholarship, worship, ownership and
exploration. Temporary allies remain autonomous.

### Persistent consequences

NPCs age, form relationships, have descendants, change professions and die.
Factions wage wars, form alliances, conquer territory and disappear. Settlements
can be damaged, destroyed, rebuilt or founded.

### Depth without chores

Food, weather, fatigue, disease, carrying capacity and travel matter, but mature
refuge upgrades and followers automate repetitive work.

## 3. Campaign structure

- Every campaign has a visible or shareable seed.
- Initial generation is a surprise; no world sliders are exposed.
- One large detailed region includes settlements, wilderness, oceans, islands,
  mountains, underground areas and other planes.
- Exploration combines continuous local movement and an abstract travel map.
- The world advances only during play.
- Major objectives are generated and optional.
- Completing an objective changes the world but never forces a campaign ending.

Possible ambitions include saving the region, gaining wealth, uncovering
secrets, serving a divinity, leading a faction, acquiring political power and
building a legacy.

## 4. World simulation

### Simulation levels

- Active: full simulation near the player.
- Regional: scheduled events and aggregate resources in loaded regions.
- Strategic: low-frequency faction, economy and family updates elsewhere.

All levels must produce deterministic, saveable outcomes.

### Geography and history

Generation order:

1. cosmology and natural laws;
2. terrain, climate, watersheds and resources;
3. ancient eras and catastrophes;
4. original species and cultures;
5. religions and original divinities;
6. settlements, routes and economies;
7. factions, notable families and conflicts;
8. current crises, opportunities and rumors.

### Time

Each world has its own calendar, day/night cycle and seasons. Time drives travel,
weather, agriculture, prices, aging, construction, deadlines and political
events.

## 5. Character creation

The player chooses:

- species from SRD 5.2.1 plus original species;
- class and legally available subclass plus original subclasses;
- background;
- appearance, body, face, hair, voice, clothing and colors;
- pronouns and identity;
- initial alignment;
- original divinity or no divinity.

Ability scores support point buy, standard array and dice rolling. Multiclassing
is supported with prerequisites and shared level progression. Balance rules may
limit abusive combinations without silently changing them.

All twelve SRD classes are planned: Barbarian, Bard, Cleric, Druid, Fighter,
Monk, Paladin, Ranger, Rogue, Sorcerer, Warlock and Wizard.

## 6. Progression

- Traditional levels 1 through 20.
- Visible experience and milestone-compatible internal hooks.
- After level 20: horizontal progression, limited epic talents, reputation,
  influence, rare equipment and voluntary legacy.
- A legacy hero may be a descendant, apprentice, ally or unrelated newcomer.
- Continuing the existing hero remains valid indefinitely.

## 7. Combat

### Structure

- Turn-based, directly in the exploration environment.
- Visually disguised isometric square grid.
- Alternating initiative to reduce long inactive periods.
- Save and resume during combat.
- Action, bonus action, movement, reaction, concentration, advantage,
  disadvantage, saving throws, conditions and death saves.

### Tactical environment

- elevation and falling;
- partial and full cover;
- destructible objects;
- difficult and hazardous terrain;
- fire, water and electricity interactions;
- friendly fire and neutral collateral damage;
- traps that can be detected, avoided, disarmed or repurposed.

### Creature behavior

Enemies assess morale, objectives, injury and personality. They may surrender,
flee, negotiate, capture targets or fight to the death. Procedural bosses receive
authored ability packages, histories, motives and discoverable weaknesses.

### Defeat

At 0 HP the normal death-save sequence begins. Defeat returns the hero to the
last refuge when fictionally possible. Consequences may include:

- lost or recoverable carried resources;
- scars, limb injuries and trauma;
- elapsed world time;
- changed or failed urgent events;
- enemy territorial recovery;
- capture, debt or rescue scenarios.

## 8. Exploration and stealth

Traversal supports walking, climbing, swimming, jumping, flying, mounts and
navigation by land or water.

Stealth considers:

- vision cones and line of sight;
- illumination and darkness;
- noise propagation;
- disguises and social access;
- tracks and disturbed terrain;
- scent for relevant creatures.

Spells and abilities work outside combat when applicable, including opening
paths, creating food, communicating with creatures and changing the environment.

## 9. Survival and inventory

Survival includes food, water, weather exposure, fatigue, disease and rest.
Short and long rests follow D&D-like limitations, consume time/resources and can
be interrupted.

Inventory combines weight and slots. Strength, containers, animals, vehicles and
the mobile refuge affect capacity. Storage location matters.

## 10. Mobile refuge

The refuge begins as a simple camp. During play the player chooses its form,
which may include caravan, magical camp, vessel or another world-appropriate
option.

Upgrade categories:

- shelter and security;
- kitchen and supplies;
- healing and treatment;
- workshop and crafting;
- library and research;
- altar and spiritual services;
- transport and storage;
- followers and specialists.

The player may also own land, businesses, ships and vehicles without making one
property the permanent center of the campaign.

## 11. Social systems

- Visible Persuasion, Deception, Intimidation and other social checks.
- Relationships include friendship, rivalry and romance.
- NPC preferences, boundaries and memories influence relationships.
- Every settlement and faction tracks reputation independently.
- Crime includes theft, trespass, smuggling, prison, trials, fines and bounties.
- Alignment evolves from patterns of action rather than isolated dialogue picks.

## 12. Economy, crafting and knowledge

Prices and availability react to weather, war, production, routes, scarcity and
player decisions.

Professions include alchemy, cooking, smithing, enchanting, hunting, fishing,
mining and commerce. Crafting combines fixed recipes with constrained
experimentation.

The codex records discovered maps, creatures, recipes, cultures and history.
Information has provenance and confidence; rumors may be false or manipulated.

## 13. Presentation and accessibility

- Modern, detailed pixel art with strong silhouettes and readable effects.
- Isometric camera with clear tactical overlays.
- Keyboard/mouse and controller parity.
- Portuguese and English.
- Beginner guidance is contextual and explains rolls without constant popups.
- Target rating 14: stylized blood and moderate dark themes, without relying on
  explicit sexual content or graphic cruelty.

Accessibility targets include remapping, scalable UI, text speed, subtitles,
color-independent indicators, reduced flashes and configurable camera motion.

## 14. Out of scope for the first production milestone

- multiplayer;
- real-time cloud-generated dialogue;
- official settings or protected D&D lore;
- the complete level 1-20 content set before the vertical slice is proven;
- offline world progress while the game is closed.
