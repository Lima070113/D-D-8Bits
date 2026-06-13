class_name TacticalUnit
extends RefCounted

var id: String
var display_name: String
var team: int
var grid_position: Vector2i
var max_hp: int
var hp: int
var armor_class: int
var attack_bonus: int
var damage_die: int
var damage_bonus: int
var movement: int
var movement_left: int
var action_available: bool


func _init(
	unit_id: String,
	unit_name: String,
	unit_team: int,
	position: Vector2i,
	unit_max_hp: int,
	unit_armor_class: int,
	unit_attack_bonus: int,
	unit_damage_die: int,
	unit_damage_bonus: int,
	unit_movement: int
) -> void:
	id = unit_id
	display_name = unit_name
	team = unit_team
	grid_position = position
	max_hp = unit_max_hp
	hp = unit_max_hp
	armor_class = unit_armor_class
	attack_bonus = unit_attack_bonus
	damage_die = unit_damage_die
	damage_bonus = unit_damage_bonus
	movement = unit_movement
	start_turn()


func start_turn() -> void:
	movement_left = movement
	action_available = is_alive()


func is_alive() -> bool:
	return hp > 0


func receive_damage(amount: int) -> int:
	var applied := mini(maxi(amount, 0), hp)
	hp -= applied
	return applied


func serialize() -> Dictionary:
	return {
		"id": id,
		"display_name": display_name,
		"team": team,
		"grid_position": [grid_position.x, grid_position.y],
		"max_hp": max_hp,
		"hp": hp,
		"armor_class": armor_class,
		"attack_bonus": attack_bonus,
		"damage_die": damage_die,
		"damage_bonus": damage_bonus,
		"movement": movement,
		"movement_left": movement_left,
		"action_available": action_available,
	}
