class_name TerrainVisualCatalog
extends RefCounted

const TacticalBattlefieldScript = preload("res://src/domain/combat/tactical_battlefield.gd")

const STONE_LIGHT := Color("#46535a")
const STONE_DARK := Color("#354148")
const STONE_EDGE := Color("#708087")
const CRACKED_LIGHT := Color("#4b4b50")
const CRACKED_DARK := Color("#38383e")
const WATER_LIGHT := Color("#2f788d")
const WATER_DARK := Color("#275d73")
const WATER_EDGE := Color("#67b8ca")
const WALL_TOP := Color("#7a777a")
const WALL_FRONT := Color("#48464d")
const WALL_SIDE := Color("#383840")
const WALL_MORTAR := Color("#292a30")


func top_color(terrain: int, cell: Vector2i) -> Color:
	var alternate := (cell.x + cell.y) % 2 == 0
	match terrain:
		TacticalBattlefieldScript.TERRAIN_CRACKED_STONE:
			return CRACKED_LIGHT if alternate else CRACKED_DARK
		TacticalBattlefieldScript.TERRAIN_WATER:
			return WATER_LIGHT if alternate else WATER_DARK
		_:
			return STONE_LIGHT if alternate else STONE_DARK


func edge_color(terrain: int) -> Color:
	if terrain == TacticalBattlefieldScript.TERRAIN_WATER:
		return WATER_EDGE
	return STONE_EDGE


func side_color(terrain: int, right_side: bool) -> Color:
	match terrain:
		TacticalBattlefieldScript.TERRAIN_WATER:
			return Color("#173b4b") if right_side else Color("#1e4858")
		TacticalBattlefieldScript.TERRAIN_CRACKED_STONE:
			return Color("#25262b") if right_side else Color("#2d2e34")
		_:
			return Color("#263138") if right_side else Color("#303b42")


func detail_variant(cell: Vector2i) -> int:
	var value := cell.x * 73856093 ^ cell.y * 19349663
	return absi(value) % 4


func wall_height(wall_type: int) -> float:
	if wall_type == TacticalBattlefieldScript.WALL_RUINED:
		return 24.0
	if wall_type == TacticalBattlefieldScript.WALL_FULL:
		return 52.0
	return 0.0
