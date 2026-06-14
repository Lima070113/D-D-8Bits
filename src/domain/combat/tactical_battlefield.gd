class_name TacticalBattlefield
extends RefCounted

const SURFACE_NONE := 0
const SURFACE_FIRE := 1

const TERRAIN_STONE := 0
const TERRAIN_CRACKED_STONE := 1
const TERRAIN_WATER := 2

const WALL_NONE := 0
const WALL_FULL := 1
const WALL_RUINED := 2

var size := Vector2i(8, 8)
var blocked_cells: Array[Vector2i] = []
var elevations: Dictionary = {}
var cover_cells: Dictionary = {}
var surfaces: Dictionary = {}
var terrain: Dictionary = {}
var walls: Dictionary = {}


func setup_demo() -> void:
	blocked_cells = []
	elevations = {
		Vector2i(4, 0): 1,
		Vector2i(5, 0): 1,
		Vector2i(4, 1): 1,
		Vector2i(5, 1): 1,
		Vector2i(6, 1): 1,
		Vector2i(5, 2): 1,
	}
	cover_cells = {
		Vector2i(2, 3): 2,
		Vector2i(2, 4): 2,
		Vector2i(4, 4): 2,
		Vector2i(5, 3): 2,
	}
	surfaces = {
		Vector2i(6, 3): SURFACE_FIRE,
		Vector2i(6, 4): SURFACE_FIRE,
	}
	terrain = {
		Vector2i(1, 2): TERRAIN_WATER,
		Vector2i(2, 2): TERRAIN_WATER,
		Vector2i(2, 1): TERRAIN_WATER,
		Vector2i(0, 0): TERRAIN_CRACKED_STONE,
		Vector2i(1, 0): TERRAIN_CRACKED_STONE,
		Vector2i(3, 1): TERRAIN_CRACKED_STONE,
		Vector2i(4, 2): TERRAIN_CRACKED_STONE,
		Vector2i(5, 4): TERRAIN_CRACKED_STONE,
		Vector2i(7, 6): TERRAIN_CRACKED_STONE,
	}
	walls = {
		Vector2i(3, 3): WALL_FULL,
		Vector2i(3, 4): WALL_RUINED,
		Vector2i(4, 3): WALL_FULL,
		Vector2i(0, 3): WALL_RUINED,
		Vector2i(7, 2): WALL_FULL,
	}


func is_inside(cell: Vector2i) -> bool:
	return cell.x >= 0 and cell.y >= 0 and cell.x < size.x and cell.y < size.y


func is_blocked(cell: Vector2i) -> bool:
	return (
		not is_inside(cell)
		or cell in blocked_cells
		or wall_at(cell) != WALL_NONE
	)


func elevation_at(cell: Vector2i) -> int:
	return int(elevations.get(cell, 0))


func cover_at(cell: Vector2i) -> int:
	return int(cover_cells.get(cell, 0))


func surface_at(cell: Vector2i) -> int:
	return int(surfaces.get(cell, SURFACE_NONE))


func terrain_at(cell: Vector2i) -> int:
	return int(terrain.get(cell, TERRAIN_STONE))


func wall_at(cell: Vector2i) -> int:
	return int(walls.get(cell, WALL_NONE))


func wall_blocks_sight(cell: Vector2i) -> bool:
	return wall_at(cell) == WALL_FULL or cell in blocked_cells


func has_line_of_sight(origin: Vector2i, target: Vector2i) -> bool:
	var delta := target - origin
	var steps := maxi(absi(delta.x), absi(delta.y))
	if steps <= 1:
		return true

	for index in range(1, steps):
		var ratio := float(index) / float(steps)
		var sample := Vector2i(
			roundi(lerpf(origin.x, target.x, ratio)),
			roundi(lerpf(origin.y, target.y, ratio))
		)
		if wall_blocks_sight(sample):
			return false
	return true


func attack_modifiers(attacker_cell: Vector2i, target_cell: Vector2i) -> Dictionary:
	var elevation_delta := elevation_at(attacker_cell) - elevation_at(target_cell)
	var attack_bonus := 1 if elevation_delta > 0 else 0
	var cover_bonus := cover_at(target_cell)
	if wall_at(target_cell) == WALL_RUINED:
		cover_bonus = maxi(cover_bonus, 2)
	return {
		"attack_bonus": attack_bonus,
		"cover_bonus": cover_bonus,
		"high_ground": elevation_delta > 0,
	}
