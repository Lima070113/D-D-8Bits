extends Control

const TacticalBattlefieldScript = preload("res://src/domain/combat/tactical_battlefield.gd")
const TerrainVisualCatalogScript = preload(
	"res://src/presentation/tactical/terrain_visual_catalog.gd"
)
const HERO_TEXTURE = preload("res://assets/art/characters/hero-fighter.png")
const RAIDER_TEXTURE = preload("res://assets/art/characters/raider.png")

const BOARD_SIZE := Vector2i(8, 8)
const TILE_SIZE := Vector2(72.0, 36.0)
const BOARD_ORIGIN := Vector2(560.0, 115.0)

const COLOR_BACKGROUND := Color("#0c0f16")
const COLOR_TILE_LIGHT := Color("#34424a")
const COLOR_TILE_DARK := Color("#29343c")
const COLOR_TILE_BORDER := Color("#64757b")
const COLOR_CURSOR := Color("#f2c14e")
const COLOR_MOVE := Color("#5ca37a")
const COLOR_BLOCKED := Color("#342f36")
const COLOR_HERO := Color("#4e83bd")
const COLOR_ENEMY := Color("#b84b4f")
const COLOR_WATER := Color("#347b91")
const COLOR_FIRE := Color("#d87532")
const COLOR_MOONLIGHT := Color("#6c8eb5")

var encounter: CombatEncounter = CombatEncounter.new()
var terrain_visuals = TerrainVisualCatalogScript.new()
var selected_cell := Vector2i(1, 5)
var awaiting_enemy_turn := false
var battle_finished := false
var camera_zoom := 1.0
var camera_offset := Vector2.ZERO

var status_label: Label
var hero_label: Label
var round_label: Label
var instructions_label: Label
var log_label: RichTextLabel
var end_turn_button: Button
var restart_button: Button


func _ready() -> void:
	var seed_value := int(GameSession.campaign.get("numeric_seed", 1))
	encounter.setup(seed_value)
	selected_cell = encounter.get_hero().grid_position
	_build_interface()
	_refresh_interface()
	queue_redraw()


func _build_interface() -> void:
	var title := Label.new()
	title.position = Vector2(28, 20)
	title.text = "D&D 8BITS"
	title.add_theme_font_size_override("font_size", 28)
	title.add_theme_color_override("font_color", Color("#f0d594"))
	add_child(title)

	round_label = Label.new()
	round_label.position = Vector2(30, 72)
	round_label.add_theme_font_size_override("font_size", 18)
	add_child(round_label)

	hero_label = Label.new()
	hero_label.position = Vector2(30, 118)
	hero_label.custom_minimum_size = Vector2(270, 130)
	hero_label.add_theme_font_size_override("font_size", 18)
	add_child(hero_label)

	status_label = Label.new()
	status_label.position = Vector2(30, 265)
	status_label.custom_minimum_size = Vector2(300, 90)
	status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	status_label.add_theme_color_override("font_color", Color("#f2c14e"))
	status_label.add_theme_font_size_override("font_size", 17)
	add_child(status_label)

	end_turn_button = Button.new()
	end_turn_button.position = Vector2(30, 370)
	end_turn_button.size = Vector2(250, 52)
	end_turn_button.pressed.connect(_end_player_turn)
	add_child(end_turn_button)

	restart_button = Button.new()
	restart_button.position = Vector2(30, 436)
	restart_button.size = Vector2(250, 48)
	restart_button.pressed.connect(_restart_battle)
	add_child(restart_button)

	instructions_label = Label.new()
	instructions_label.position = Vector2(30, 525)
	instructions_label.custom_minimum_size = Vector2(300, 150)
	instructions_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	instructions_label.add_theme_color_override("font_color", Color("#9ba7b5"))
	add_child(instructions_label)

	log_label = RichTextLabel.new()
	log_label.position = Vector2(930, 70)
	log_label.size = Vector2(320, 590)
	log_label.bbcode_enabled = true
	log_label.fit_content = false
	log_label.scroll_following = true
	log_label.add_theme_font_size_override("normal_font_size", 16)
	add_child(log_label)
	_add_log(tr("COMBAT_STARTED"))


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), COLOR_BACKGROUND)
	_draw_atmosphere()
	for star in [
		Vector2(374, 38), Vector2(492, 71), Vector2(716, 42),
		Vector2(855, 92), Vector2(1137, 34), Vector2(1210, 178),
	]:
		draw_circle(star, 1.5, Color("#647386"))
	draw_rect(Rect2(18, 14, 294, 690), Color("#111722"))
	draw_rect(Rect2(920, 54, 342, 630), Color("#111722"))
	draw_rect(Rect2(18, 14, 294, 690), Color("#334052"), false, 2)
	draw_rect(Rect2(920, 54, 342, 630), Color("#334052"), false, 2)
	draw_line(Vector2(330, 30), Vector2(900, 30), Color("#c89945"), 2)
	for diagonal in range(BOARD_SIZE.x + BOARD_SIZE.y - 1):
		for x in range(BOARD_SIZE.x):
			var y := diagonal - x
			if y < 0 or y >= BOARD_SIZE.y:
				continue
			_draw_cell(Vector2i(x, y))

	_draw_boundary_walls()
	for diagonal in range(BOARD_SIZE.x + BOARD_SIZE.y - 1):
		for x in range(BOARD_SIZE.x):
			var y := diagonal - x
			if y < 0 or y >= BOARD_SIZE.y:
				continue
			var cell := Vector2i(x, y)
			if encounter.battlefield.wall_at(cell) != TacticalBattlefieldScript.WALL_NONE:
				_draw_wall(cell)

	var sorted_units := encounter.units.duplicate()
	sorted_units.sort_custom(
		func(first, second): return (
			first.grid_position.x + first.grid_position.y
			< second.grid_position.x + second.grid_position.y
		)
	)
	for unit in sorted_units:
		if unit.is_alive():
			_draw_unit(unit)

	_draw_vignette()


func _draw_atmosphere() -> void:
	draw_circle(Vector2(785, 96), 105, Color(0.15, 0.21, 0.32, 0.16))
	draw_circle(Vector2(785, 96), 64, Color(0.28, 0.39, 0.55, 0.12))
	draw_circle(Vector2(785, 96), 28, Color(0.58, 0.68, 0.78, 0.18))

	var ruin_color := Color("#131b25")
	draw_colored_polygon(
		PackedVector2Array([
			Vector2(330, 175), Vector2(390, 128), Vector2(445, 160),
			Vector2(505, 104), Vector2(565, 151), Vector2(620, 119),
			Vector2(690, 172), Vector2(690, 270), Vector2(330, 270),
		]),
		ruin_color
	)
	for x in range(350, 890, 86):
		draw_rect(Rect2(x, 180 + ((x / 86) % 2) * 16, 22, 112), Color("#18222c"))
		draw_rect(Rect2(x - 7, 173 + ((x / 86) % 2) * 16, 36, 10), Color("#202c37"))

	for position in [Vector2(430, 177), Vector2(854, 224)]:
		draw_circle(position, 22, Color(0.91, 0.43, 0.15, 0.06))
		draw_circle(position, 12, Color(1.0, 0.62, 0.2, 0.11))
		draw_circle(position, 4, Color("#ffb347"))


func _draw_vignette() -> void:
	for index in range(8):
		var alpha := 0.018 + index * 0.006
		draw_rect(
			Rect2(index * 5, index * 5, size.x - index * 10, size.y - index * 10),
			Color(0, 0, 0, alpha),
			false,
			8
		)


func _draw_cell(cell: Vector2i) -> void:
	var center := _grid_to_screen(cell)
	var points := PackedVector2Array([
		center + Vector2(0, -TILE_SIZE.y / 2.0) * camera_zoom,
		center + Vector2(TILE_SIZE.x / 2.0, 0) * camera_zoom,
		center + Vector2(0, TILE_SIZE.y / 2.0) * camera_zoom,
		center + Vector2(-TILE_SIZE.x / 2.0, 0) * camera_zoom,
	])
	var terrain: int = encounter.battlefield.terrain_at(cell)
	var color: Color = terrain_visuals.top_color(terrain, cell)
	var surface: int = encounter.battlefield.surface_at(cell)
	if surface == TacticalBattlefieldScript.SURFACE_FIRE:
		color = color.lerp(COLOR_FIRE, 0.72)
	if encounter.battlefield.is_blocked(cell):
		color = COLOR_BLOCKED
	elif _is_reachable_from_hero(cell):
		color = color.lerp(COLOR_MOVE, 0.35)
	if cell == selected_cell:
		color = color.lerp(COLOR_CURSOR, 0.5)
	var elevation: int = encounter.battlefield.elevation_at(cell)
	if elevation > 0 and not encounter.battlefield.is_blocked(cell):
		_draw_elevation_sides(points, terrain, elevation)

	draw_colored_polygon(points, color)
	draw_polyline(
		points + PackedVector2Array([points[0]]),
		terrain_visuals.edge_color(terrain),
		1.5
	)
	_draw_terrain_detail(cell, center, terrain)

	if encounter.battlefield.cover_at(cell) > 0:
		draw_line(
			center + Vector2(-18, -5) * camera_zoom,
			center + Vector2(18, 5) * camera_zoom,
			Color("#a48b68"),
			5 * camera_zoom
		)

	if surface == TacticalBattlefieldScript.SURFACE_FIRE:
		draw_circle(center - Vector2(0, 8) * camera_zoom, 7 * camera_zoom, Color("#ffb347"))
		draw_circle(center - Vector2(4, 13) * camera_zoom, 4 * camera_zoom, Color("#e84f2f"))
	elif terrain == TacticalBattlefieldScript.TERRAIN_WATER:
		draw_arc(center, 13 * camera_zoom, 0.2, 2.9, 12, Color("#72c8d8"), 2 * camera_zoom)


func _draw_boundary_walls() -> void:
	var boundary_cells: Array[Vector2i] = [
		Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0),
		Vector2i(5, 0), Vector2i(6, 0), Vector2i(7, 0),
		Vector2i(0, 1), Vector2i(0, 2), Vector2i(0, 5), Vector2i(0, 6),
		Vector2i(2, 7), Vector2i(3, 7), Vector2i(4, 7),
		Vector2i(7, 5), Vector2i(7, 6),
	]
	for cell in boundary_cells:
		_draw_parapet(cell)


func _draw_parapet(cell: Vector2i) -> void:
	var center := _grid_to_screen(cell)
	var points := PackedVector2Array([
		center + Vector2(0, -TILE_SIZE.y / 2.0) * camera_zoom,
		center + Vector2(TILE_SIZE.x / 2.0, 0) * camera_zoom,
		center + Vector2(0, TILE_SIZE.y / 2.0) * camera_zoom,
		center + Vector2(-TILE_SIZE.x / 2.0, 0) * camera_zoom,
	])
	var variant := terrain_visuals.detail_variant(cell)
	var height := (9.0 if variant == 0 else 14.0) * camera_zoom
	var edge_start: Vector2
	var edge_end: Vector2
	if cell.y == 0:
		edge_start = points[0]
		edge_end = points[1]
	elif cell.x == 0:
		edge_start = points[3]
		edge_end = points[0]
	elif cell.y == BOARD_SIZE.y - 1:
		edge_start = points[3]
		edge_end = points[2]
	else:
		edge_start = points[2]
		edge_end = points[1]

	var top_start := edge_start - Vector2(0, height)
	var top_end := edge_end - Vector2(0, height)
	draw_colored_polygon(
		PackedVector2Array([
			top_start, top_end, edge_end, edge_start,
		]),
		Color("#32343b")
	)
	draw_line(top_start, top_end, Color("#77777b"), 2 * camera_zoom)
	draw_line(edge_start, edge_end, Color("#20242a"), 1.5 * camera_zoom)
	if variant == 0:
		var middle := top_start.lerp(top_end, 0.52)
		draw_line(
			middle,
			middle + Vector2(3, height),
			Color("#1f2228"),
			2 * camera_zoom
		)


func _draw_wall(cell: Vector2i) -> void:
	var wall_type: int = encounter.battlefield.wall_at(cell)
	var center := _grid_to_screen(cell)
	var wall_height := terrain_visuals.wall_height(wall_type) * camera_zoom
	var width := 54.0 * camera_zoom
	var depth := 13.0 * camera_zoom
	var base_y := center.y + 2 * camera_zoom
	var top_y := base_y - wall_height
	var left := Vector2(center.x - width / 2.0, base_y)
	var right := Vector2(center.x + width / 2.0, base_y)

	draw_colored_polygon(
		PackedVector2Array([
			Vector2(left.x, top_y),
			Vector2(right.x, top_y),
			right,
			left,
		]),
		terrain_visuals.WALL_FRONT
	)
	draw_colored_polygon(
		PackedVector2Array([
			Vector2(left.x, top_y),
			Vector2(left.x + depth, top_y - depth * 0.45),
			Vector2(right.x + depth, top_y - depth * 0.45),
			Vector2(right.x, top_y),
		]),
		terrain_visuals.WALL_TOP
	)
	draw_colored_polygon(
		PackedVector2Array([
			Vector2(right.x, top_y),
			Vector2(right.x + depth, top_y - depth * 0.45),
			Vector2(right.x + depth, base_y - depth * 0.45),
			right,
		]),
		terrain_visuals.WALL_SIDE
	)

	var rows := 3 if wall_type == TacticalBattlefieldScript.WALL_FULL else 1
	for row in range(rows):
		var mortar_y := base_y - (row + 1) * wall_height / float(rows + 1)
		draw_line(
			Vector2(left.x + 3, mortar_y),
			Vector2(right.x - 3, mortar_y),
			terrain_visuals.WALL_MORTAR,
			1.2 * camera_zoom
		)

	if wall_type == TacticalBattlefieldScript.WALL_RUINED:
		var notch := terrain_visuals.detail_variant(cell)
		var notch_x := lerpf(left.x + 8, right.x - 8, float(notch) / 3.0)
		draw_colored_polygon(
			PackedVector2Array([
				Vector2(notch_x - 8, top_y - 2),
				Vector2(notch_x, top_y + 10),
				Vector2(notch_x + 9, top_y - 2),
			]),
			COLOR_BACKGROUND
		)


func _draw_elevation_sides(
	points: PackedVector2Array,
	terrain: int,
	elevation: int
) -> void:
	var depth := 12.0 * elevation * camera_zoom
	var bottom := PackedVector2Array()
	for point in points:
		bottom.append(point + Vector2(0, depth))

	var left_face := PackedVector2Array([
		points[3], points[2], bottom[2], bottom[3],
	])
	var right_face := PackedVector2Array([
		points[2], points[1], bottom[1], bottom[2],
	])
	draw_colored_polygon(left_face, terrain_visuals.side_color(terrain, false))
	draw_colored_polygon(right_face, terrain_visuals.side_color(terrain, true))
	draw_polyline(
		left_face + PackedVector2Array([left_face[0]]),
		Color("#172027"),
		1.0
	)
	draw_polyline(
		right_face + PackedVector2Array([right_face[0]]),
		Color("#172027"),
		1.0
	)


func _draw_terrain_detail(cell: Vector2i, center: Vector2, terrain: int) -> void:
	var variant: int = terrain_visuals.detail_variant(cell)
	if terrain == TacticalBattlefieldScript.TERRAIN_WATER:
		var offset := float(variant - 1) * 3.0 * camera_zoom
		draw_line(
			center + Vector2(-15, offset) * camera_zoom,
			center + Vector2(3, offset + 4) * camera_zoom,
			Color(0.48, 0.82, 0.9, 0.72),
			1.5 * camera_zoom
		)
		return

	if terrain == TacticalBattlefieldScript.TERRAIN_CRACKED_STONE:
		var direction := -1.0 if variant % 2 == 0 else 1.0
		draw_polyline(
			PackedVector2Array([
				center + Vector2(-10 * direction, -3) * camera_zoom,
				center + Vector2(-2 * direction, 1) * camera_zoom,
				center + Vector2(5 * direction, -1) * camera_zoom,
				center + Vector2(11 * direction, 4) * camera_zoom,
			]),
			Color("#22262b"),
			1.5 * camera_zoom
		)
		return

	if variant == 0:
		draw_circle(
			center + Vector2(-9, 2) * camera_zoom,
			2.0 * camera_zoom,
			Color(0.25, 0.38, 0.32, 0.65)
		)


func _draw_unit(unit: TacticalUnit) -> void:
	var base := _grid_to_screen(unit.grid_position)
	var is_hero := unit.team == CombatEncounter.TEAM_HERO
	var texture: Texture2D = HERO_TEXTURE if is_hero else RAIDER_TEXTURE
	var ring_color := COLOR_HERO if is_hero else COLOR_ENEMY
	var sprite_size := Vector2(112, 112) * camera_zoom
	var sprite_rect := Rect2(
		base + Vector2(-56, -103) * camera_zoom,
		sprite_size
	)

	draw_set_transform(Vector2.ZERO, 0.0, Vector2(1.0, 0.44))
	draw_circle(base / Vector2(1.0, 0.44), 27 * camera_zoom, Color(0, 0, 0, 0.42))
	draw_set_transform(Vector2.ZERO)
	draw_arc(base, 27 * camera_zoom, 0, TAU, 32, ring_color, 3 * camera_zoom)
	if unit.grid_position == selected_cell:
		draw_arc(
			base,
			32 * camera_zoom,
			0,
			TAU,
			32,
			Color("#f2c14e"),
			2 * camera_zoom
		)

	var tint := Color.WHITE
	if unit.id == "raider_2":
		tint = Color("#d8c2b4")
	draw_texture_rect(texture, sprite_rect, false, tint)

	var hp_ratio := float(unit.hp) / float(unit.max_hp)
	draw_rect(
		Rect2(base + Vector2(-20, 12) * camera_zoom, Vector2(40, 5) * camera_zoom),
		Color("#151820")
	)
	draw_rect(
		Rect2(
			base + Vector2(-20, 12) * camera_zoom,
			Vector2(40 * hp_ratio, 5) * camera_zoom
		),
		Color("#61b86b")
	)
	var font := ThemeDB.fallback_font
	draw_string(
		font,
		base + Vector2(-34, 29) * camera_zoom,
		tr(unit.display_name),
		HORIZONTAL_ALIGNMENT_CENTER,
		68 * camera_zoom,
		11 * camera_zoom,
		Color("#dfe7ef")
	)


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			_set_camera_zoom(camera_zoom + 0.1)
			return
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_set_camera_zoom(camera_zoom - 0.1)
			return
		if event.button_index == MOUSE_BUTTON_LEFT and not battle_finished and not awaiting_enemy_turn:
			var clicked := _screen_to_grid(event.position)
			if _is_inside_board(clicked):
				selected_cell = clicked
				_confirm_selected_cell()


func _unhandled_input(event: InputEvent) -> void:
	if battle_finished or awaiting_enemy_turn:
		return

	var direction := Vector2i.ZERO
	if event.is_action_pressed("move_north"):
		direction = Vector2i(0, -1)
	elif event.is_action_pressed("move_south"):
		direction = Vector2i(0, 1)
	elif event.is_action_pressed("move_west"):
		direction = Vector2i(-1, 0)
	elif event.is_action_pressed("move_east"):
		direction = Vector2i(1, 0)
	elif event.is_action_pressed("ui_accept"):
		_confirm_selected_cell()
	elif event.is_action_pressed("end_turn"):
		_end_player_turn()
	elif event.is_action_pressed("camera_zoom_in"):
		_set_camera_zoom(camera_zoom + 0.1)
	elif event.is_action_pressed("camera_zoom_out"):
		_set_camera_zoom(camera_zoom - 0.1)

	if direction != Vector2i.ZERO:
		selected_cell = Vector2i(
			clampi(selected_cell.x + direction.x, 0, BOARD_SIZE.x - 1),
			clampi(selected_cell.y + direction.y, 0, BOARD_SIZE.y - 1)
		)
		queue_redraw()


func _confirm_selected_cell() -> void:
	if encounter.active_team != CombatEncounter.TEAM_HERO:
		return

	var hero := encounter.get_hero()
	var target := encounter.unit_at(selected_cell)
	if target != null and target.team == CombatEncounter.TEAM_ENEMY:
		var result := encounter.attack(hero, target)
		if not result.is_empty():
			_describe_attack(result)
			_after_player_action()
			return

	var movement_result := encounter.move_unit(hero, selected_cell)
	if not movement_result.is_empty():
		_add_log(
			tr("COMBAT_HERO_MOVED") % hero.movement_left
		)
		for reaction in movement_result.reactions:
			if not reaction.is_empty():
				_describe_attack(reaction)
		if movement_result.surface_damage > 0:
			_add_log(tr("COMBAT_FIRE_DAMAGE") % [tr(hero.display_name), movement_result.surface_damage])
		if encounter.is_defeat():
			battle_finished = true
		_refresh_interface()
		queue_redraw()


func _after_player_action() -> void:
	if encounter.is_victory():
		battle_finished = true
		_add_log("[color=#f2c14e]%s[/color]" % tr("COMBAT_VICTORY"))
		_refresh_interface()
		queue_redraw()
		return
	_refresh_interface()
	queue_redraw()


func _end_player_turn() -> void:
	if battle_finished or awaiting_enemy_turn:
		return
	awaiting_enemy_turn = true
	encounter.finish_team_turn()
	_refresh_interface()
	queue_redraw()
	await get_tree().create_timer(0.35).timeout
	await _run_enemy_team()


func _run_enemy_team() -> void:
	var hero := encounter.get_hero()
	for enemy in encounter.get_living_units(CombatEncounter.TEAM_ENEMY):
		if not hero.is_alive():
			break
		if encounter.can_attack(enemy, hero):
			_describe_attack(encounter.attack(enemy, hero))
		else:
			var step := _enemy_step_toward(enemy, hero)
			if step != enemy.grid_position:
				var movement_result := encounter.move_unit(enemy, step)
				_add_log(
					tr("COMBAT_ENEMY_MOVED") % tr(enemy.display_name)
				)
				for reaction in movement_result.reactions:
					if not reaction.is_empty():
						_describe_attack(reaction)
				if movement_result.surface_damage > 0:
					_add_log(
						tr("COMBAT_FIRE_DAMAGE")
						% [tr(enemy.display_name), movement_result.surface_damage]
					)
				queue_redraw()
				await get_tree().create_timer(0.2).timeout
			if encounter.can_attack(enemy, hero):
				_describe_attack(encounter.attack(enemy, hero))
		await get_tree().create_timer(0.3).timeout

	if encounter.is_defeat():
		battle_finished = true
		_add_log("[color=#d35d62]%s[/color]" % tr("COMBAT_DEFEAT"))
	else:
		encounter.finish_team_turn()
		selected_cell = hero.grid_position
	awaiting_enemy_turn = false
	_refresh_interface()
	queue_redraw()


func _enemy_step_toward(enemy: TacticalUnit, hero: TacticalUnit) -> Vector2i:
	var candidates: Array[Vector2i] = [
		enemy.grid_position + Vector2i(1, 0),
		enemy.grid_position + Vector2i(-1, 0),
		enemy.grid_position + Vector2i(0, 1),
		enemy.grid_position + Vector2i(0, -1),
	]
	candidates.sort_custom(
		func(first, second): return (
			encounter.manhattan_distance(first, hero.grid_position)
			< encounter.manhattan_distance(second, hero.grid_position)
		)
	)
	for candidate in candidates:
		if _is_inside_board(candidate) and encounter.can_move(enemy, candidate):
			return candidate
	return enemy.grid_position


func _describe_attack(result: Dictionary) -> void:
	var message: String
	if result.hit:
		message = tr("COMBAT_HIT") % [
			tr(result.attacker),
			tr(result.target),
			result.d20,
			result.bonus,
			result.total,
			result.armor_class,
			result.damage,
			(" " + tr("COMBAT_CRITICAL")) if result.critical else "",
		]
	else:
		message = tr("COMBAT_MISS") % [
			tr(result.attacker),
			tr(result.target),
			result.d20,
			result.bonus,
			result.total,
			result.armor_class,
		]
	if result.reaction:
		message = "%s %s" % [tr("COMBAT_OPPORTUNITY"), message]
	if result.high_ground:
		message += " " + tr("COMBAT_HIGH_GROUND")
	if result.cover_bonus > 0:
		message += " " + (tr("COMBAT_COVER") % result.cover_bonus)
	_add_log(message)


func _restart_battle() -> void:
	var seed_value := int(GameSession.campaign.get("numeric_seed", 1))
	encounter.setup(seed_value)
	selected_cell = encounter.get_hero().grid_position
	awaiting_enemy_turn = false
	battle_finished = false
	log_label.clear()
	_add_log(tr("COMBAT_RESTARTED"))
	_refresh_interface()
	queue_redraw()


func _refresh_interface() -> void:
	var hero := encounter.get_hero()
	round_label.text = tr("COMBAT_ROUND") % [
		encounter.round_number,
		tr("COMBAT_PLAYER_TURN")
		if encounter.active_team == CombatEncounter.TEAM_HERO
		else tr("COMBAT_ENEMY_TURN"),
	]
	hero_label.text = tr("COMBAT_HERO_STATS") % [
		hero.hp,
		hero.max_hp,
		hero.armor_class,
		hero.movement_left,
		tr("YES") if hero.action_available else tr("NO"),
		hero.attack_range,
	]
	status_label.text = _status_text()
	end_turn_button.text = tr("COMBAT_END_TURN")
	restart_button.text = tr("COMBAT_RESTART")
	instructions_label.text = tr("COMBAT_INSTRUCTIONS")
	end_turn_button.disabled = awaiting_enemy_turn or battle_finished


func _status_text() -> String:
	if encounter.is_victory():
		return tr("COMBAT_VICTORY_STATUS")
	if encounter.is_defeat():
		return tr("COMBAT_DEFEAT_STATUS")
	if awaiting_enemy_turn or encounter.active_team == CombatEncounter.TEAM_ENEMY:
		return tr("COMBAT_ENEMIES_ACTING")
	var selected_unit := encounter.unit_at(selected_cell)
	if selected_unit != null and selected_unit.team == CombatEncounter.TEAM_ENEMY:
		return tr("COMBAT_TARGET_STATS") % [
			tr(selected_unit.display_name),
			selected_unit.hp,
			selected_unit.max_hp,
			selected_unit.armor_class,
		]
	return tr("COMBAT_SELECTED_CELL") % [selected_cell.x + 1, selected_cell.y + 1]


func _add_log(message: String) -> void:
	log_label.append_text("[color=#8995a5]---[/color]\n%s\n" % message)


func _is_reachable_from_hero(cell: Vector2i) -> bool:
	if encounter.active_team != CombatEncounter.TEAM_HERO or awaiting_enemy_turn:
		return false
	var hero := encounter.get_hero()
	return encounter.can_move(hero, cell)


func _grid_to_screen(cell: Vector2i) -> Vector2:
	var elevation_offset := Vector2(
		0,
		-9 * encounter.battlefield.elevation_at(cell) * camera_zoom
	)
	return BOARD_ORIGIN + camera_offset + Vector2(
		(cell.x - cell.y) * TILE_SIZE.x / 2.0,
		(cell.x + cell.y) * TILE_SIZE.y / 2.0
	) * camera_zoom + elevation_offset


func _screen_to_grid(screen_position: Vector2) -> Vector2i:
	var local := (screen_position - BOARD_ORIGIN - camera_offset) / camera_zoom
	var grid_x := (local.x / (TILE_SIZE.x / 2.0) + local.y / (TILE_SIZE.y / 2.0)) / 2.0
	var grid_y := (local.y / (TILE_SIZE.y / 2.0) - local.x / (TILE_SIZE.x / 2.0)) / 2.0
	return Vector2i(roundi(grid_x), roundi(grid_y))


func _is_inside_board(cell: Vector2i) -> bool:
	return cell.x >= 0 and cell.y >= 0 and cell.x < BOARD_SIZE.x and cell.y < BOARD_SIZE.y


func _set_camera_zoom(value: float) -> void:
	camera_zoom = clampf(value, 0.75, 1.3)
	queue_redraw()
