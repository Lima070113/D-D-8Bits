extends SceneTree

func _init() -> void:
	var encounter: CombatEncounter = CombatEncounter.new()
	encounter.setup(12345)

	var hero: TacticalUnit = encounter.get_hero()
	assert(hero.hp == 24)
	assert(hero.movement_left == 4)
	assert(encounter.move_unit(hero, Vector2i(2, 5), []))
	assert(hero.movement_left == 3)
	assert(not encounter.move_unit(hero, Vector2i(4, 5), []))

	var target: TacticalUnit = encounter.get_living_units(CombatEncounter.TEAM_ENEMY)[1]
	hero.grid_position = Vector2i(5, 5)
	assert(encounter.can_attack(hero, target))
	var result := encounter.attack(hero, target)
	assert(not result.is_empty())
	assert(result.has("d20"))
	assert(not hero.action_available)

	encounter.finish_team_turn()
	assert(encounter.active_team == CombatEncounter.TEAM_ENEMY)
	encounter.finish_team_turn()
	assert(encounter.active_team == CombatEncounter.TEAM_HERO)
	assert(encounter.round_number == 2)

	print("combat_encounter_test: PASS")
	quit(0)
