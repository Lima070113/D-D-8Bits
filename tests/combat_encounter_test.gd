extends SceneTree

const TacticalBattlefieldScript = preload("res://src/domain/combat/tactical_battlefield.gd")

func _init() -> void:
	var encounter: CombatEncounter = CombatEncounter.new()
	encounter.setup(12345)

	var hero: TacticalUnit = encounter.get_hero()
	assert(hero.hp == 24)
	assert(hero.movement_left == 4)
	assert(not encounter.move_unit(hero, Vector2i(2, 5)).is_empty())
	assert(hero.movement_left == 3)
	assert(encounter.move_unit(hero, Vector2i(4, 5)).is_empty())

	var target: TacticalUnit = encounter.get_living_units(CombatEncounter.TEAM_ENEMY)[1]
	hero.grid_position = Vector2i(5, 5)
	assert(encounter.can_attack(hero, target))
	var result := encounter.attack(hero, target)
	assert(not result.is_empty())
	assert(result.has("d20"))
	assert(not hero.action_available)

	var scout: TacticalUnit = encounter.get_living_units(CombatEncounter.TEAM_ENEMY)[1]
	assert(scout.attack_range == 4)
	assert(
		encounter.battlefield.terrain_at(Vector2i(1, 2))
		== TacticalBattlefieldScript.TERRAIN_WATER
	)
	assert(
		encounter.battlefield.terrain_at(Vector2i(0, 0))
		== TacticalBattlefieldScript.TERRAIN_CRACKED_STONE
	)
	assert(
		encounter.battlefield.surface_at(Vector2i(6, 3))
		== TacticalBattlefieldScript.SURFACE_FIRE
	)
	assert(encounter.battlefield.elevation_at(Vector2i(5, 2)) == 1)
	assert(
		encounter.battlefield.wall_at(Vector2i(3, 3))
		== TacticalBattlefieldScript.WALL_FULL
	)
	assert(
		encounter.battlefield.wall_at(Vector2i(3, 4))
		== TacticalBattlefieldScript.WALL_RUINED
	)
	assert(encounter.battlefield.is_blocked(Vector2i(3, 4)))
	assert(not encounter.battlefield.has_line_of_sight(Vector2i(2, 3), Vector2i(4, 3)))
	assert(encounter.battlefield.has_line_of_sight(Vector2i(2, 4), Vector2i(4, 4)))
	assert(encounter.battlefield.attack_modifiers(Vector2i(2, 4), Vector2i(3, 4)).cover_bonus == 2)

	encounter.finish_team_turn()
	assert(encounter.active_team == CombatEncounter.TEAM_ENEMY)
	encounter.finish_team_turn()
	assert(encounter.active_team == CombatEncounter.TEAM_HERO)
	assert(encounter.round_number == 2)

	var reaction_encounter: CombatEncounter = CombatEncounter.new()
	reaction_encounter.setup(777)
	var reaction_hero := reaction_encounter.get_hero()
	var reaction_enemy := reaction_encounter.get_living_units(CombatEncounter.TEAM_ENEMY)[0]
	reaction_hero.grid_position = Vector2i(4, 2)
	reaction_enemy.grid_position = Vector2i(5, 2)
	var movement_result := reaction_encounter.move_unit(reaction_hero, Vector2i(4, 1))
	assert(movement_result.reactions.size() == 1)
	assert(not reaction_enemy.reaction_available)

	print("combat_encounter_test: PASS")
	quit(0)
