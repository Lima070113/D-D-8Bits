class_name CombatEncounter
extends RefCounted

const TacticalBattlefieldScript = preload("res://src/domain/combat/tactical_battlefield.gd")

const TEAM_HERO := 0
const TEAM_ENEMY := 1

var units: Array[TacticalUnit] = []
var active_team := TEAM_HERO
var round_number := 1
var random := RandomNumberGenerator.new()
var battlefield = TacticalBattlefieldScript.new()


func setup(numeric_seed: int) -> void:
	random.seed = numeric_seed
	battlefield.setup_demo()
	units = [
		TacticalUnit.new("hero", "UNIT_ALDRIC", TEAM_HERO, Vector2i(1, 5), 24, 16, 5, 8, 3, 1, 4),
		TacticalUnit.new("raider_1", "UNIT_RAIDER", TEAM_ENEMY, Vector2i(5, 2), 11, 12, 3, 6, 1, 1, 3),
		TacticalUnit.new("raider_2", "UNIT_SCOUT", TEAM_ENEMY, Vector2i(6, 5), 9, 13, 4, 6, 0, 4, 4),
	]
	begin_team_turn(TEAM_HERO)


func begin_team_turn(team: int) -> void:
	active_team = team
	for unit in units:
		if unit.team == team:
			unit.start_turn()


func finish_team_turn() -> void:
	if active_team == TEAM_HERO:
		begin_team_turn(TEAM_ENEMY)
	else:
		round_number += 1
		begin_team_turn(TEAM_HERO)


func get_hero() -> TacticalUnit:
	for unit in units:
		if unit.team == TEAM_HERO:
			return unit
	return null


func get_living_units(team: int) -> Array[TacticalUnit]:
	var result: Array[TacticalUnit] = []
	for unit in units:
		if unit.team == team and unit.is_alive():
			result.append(unit)
	return result


func unit_at(cell: Vector2i) -> TacticalUnit:
	for unit in units:
		if unit.is_alive() and unit.grid_position == cell:
			return unit
	return null


func can_move(unit: TacticalUnit, cell: Vector2i) -> bool:
	if unit == null or not unit.is_alive() or unit.team != active_team:
		return false
	if unit.movement_left <= 0 or unit_at(cell) != null or battlefield.is_blocked(cell):
		return false
	if absi(
		battlefield.elevation_at(unit.grid_position) - battlefield.elevation_at(cell)
	) > 1:
		return false
	return manhattan_distance(unit.grid_position, cell) == 1


func move_unit(unit: TacticalUnit, cell: Vector2i) -> Dictionary:
	if not can_move(unit, cell):
		return {}
	var origin := unit.grid_position
	var reactions: Array[Dictionary] = []
	for enemy in get_living_units(TEAM_ENEMY if unit.team == TEAM_HERO else TEAM_HERO):
		if (
			enemy.reaction_available
			and enemy.attack_range == 1
			and manhattan_distance(enemy.grid_position, origin) == 1
			and manhattan_distance(enemy.grid_position, cell) > 1
		):
			enemy.reaction_available = false
			reactions.append(attack(enemy, unit, true))
			if not unit.is_alive():
				break
	unit.grid_position = cell
	unit.movement_left -= 1
	var surface_damage := 0
	if battlefield.surface_at(cell) == TacticalBattlefieldScript.SURFACE_FIRE:
		surface_damage = unit.receive_damage(random.randi_range(1, 4))
	return {
		"moved": true,
		"reactions": reactions,
		"surface_damage": surface_damage,
	}


func can_attack(attacker: TacticalUnit, target: TacticalUnit) -> bool:
	if attacker == null or target == null:
		return false
	if not attacker.is_alive() or not target.is_alive():
		return false
	if attacker.team != active_team or attacker.team == target.team:
		return false
	return (
		attacker.action_available
		and manhattan_distance(attacker.grid_position, target.grid_position) <= attacker.attack_range
		and battlefield.has_line_of_sight(attacker.grid_position, target.grid_position)
	)


func attack(attacker: TacticalUnit, target: TacticalUnit, is_reaction := false) -> Dictionary:
	if not is_reaction and not can_attack(attacker, target):
		return {}
	if is_reaction and (
		not attacker.is_alive()
		or not target.is_alive()
		or attacker.team == target.team
		or manhattan_distance(attacker.grid_position, target.grid_position) != 1
	):
		return {}

	if not is_reaction:
		attacker.action_available = false
	var tactical := battlefield.attack_modifiers(
		attacker.grid_position, target.grid_position
	)
	var d20 := random.randi_range(1, 20)
	var total := d20 + attacker.attack_bonus + int(tactical.attack_bonus)
	var effective_armor_class := target.armor_class + int(tactical.cover_bonus)
	var critical := d20 == 20
	var hit := critical or (d20 != 1 and total >= effective_armor_class)
	var damage := 0

	if hit:
		damage = random.randi_range(1, attacker.damage_die) + attacker.damage_bonus
		if critical:
			damage += random.randi_range(1, attacker.damage_die)
		damage = target.receive_damage(damage)

	return {
		"attacker": attacker.display_name,
		"target": target.display_name,
		"d20": d20,
		"bonus": attacker.attack_bonus,
		"tactical_bonus": tactical.attack_bonus,
		"total": total,
		"armor_class": effective_armor_class,
		"cover_bonus": tactical.cover_bonus,
		"high_ground": tactical.high_ground,
		"critical": critical,
		"reaction": is_reaction,
		"hit": hit,
		"damage": damage,
		"target_defeated": not target.is_alive(),
	}


func is_victory() -> bool:
	return get_living_units(TEAM_ENEMY).is_empty()


func is_defeat() -> bool:
	return get_living_units(TEAM_HERO).is_empty()


func manhattan_distance(first: Vector2i, second: Vector2i) -> int:
	return absi(first.x - second.x) + absi(first.y - second.y)
