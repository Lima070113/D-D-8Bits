class_name CombatEncounter
extends RefCounted

const TEAM_HERO := 0
const TEAM_ENEMY := 1

var units: Array[TacticalUnit] = []
var active_team := TEAM_HERO
var round_number := 1
var random := RandomNumberGenerator.new()


func setup(numeric_seed: int) -> void:
	random.seed = numeric_seed
	units = [
		TacticalUnit.new("hero", "UNIT_ALDRIC", TEAM_HERO, Vector2i(1, 5), 24, 16, 5, 8, 3, 4),
		TacticalUnit.new("raider_1", "UNIT_RAIDER", TEAM_ENEMY, Vector2i(5, 2), 11, 12, 3, 6, 1, 3),
		TacticalUnit.new("raider_2", "UNIT_SCOUT", TEAM_ENEMY, Vector2i(6, 5), 9, 13, 4, 6, 0, 4),
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


func can_move(unit: TacticalUnit, cell: Vector2i, blocked_cells: Array[Vector2i]) -> bool:
	if unit == null or not unit.is_alive() or unit.team != active_team:
		return false
	if unit.movement_left <= 0 or unit_at(cell) != null or cell in blocked_cells:
		return false
	return manhattan_distance(unit.grid_position, cell) == 1


func move_unit(unit: TacticalUnit, cell: Vector2i, blocked_cells: Array[Vector2i]) -> bool:
	if not can_move(unit, cell, blocked_cells):
		return false
	unit.grid_position = cell
	unit.movement_left -= 1
	return true


func can_attack(attacker: TacticalUnit, target: TacticalUnit) -> bool:
	if attacker == null or target == null:
		return false
	if not attacker.is_alive() or not target.is_alive():
		return false
	if attacker.team != active_team or attacker.team == target.team:
		return false
	return attacker.action_available and manhattan_distance(
		attacker.grid_position, target.grid_position
	) == 1


func attack(attacker: TacticalUnit, target: TacticalUnit) -> Dictionary:
	if not can_attack(attacker, target):
		return {}

	attacker.action_available = false
	var d20 := random.randi_range(1, 20)
	var total := d20 + attacker.attack_bonus
	var critical := d20 == 20
	var hit := critical or (d20 != 1 and total >= target.armor_class)
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
		"total": total,
		"armor_class": target.armor_class,
		"critical": critical,
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
