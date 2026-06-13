extends Control

const BOARD_SIZE := Vector2i(8, 8)
const TILE_SIZE := Vector2(72.0, 36.0)
const BOARD_ORIGIN := Vector2(560.0, 115.0)
const BLOCKED_CELLS: Array[Vector2i] = [
	Vector2i(3, 3),
	Vector2i(3, 4),
	Vector2i(4, 3),
]

const COLOR_BACKGROUND := Color("#0c0f16")
const COLOR_TILE_LIGHT := Color("#34424a")
const COLOR_TILE_DARK := Color("#29343c")
const COLOR_TILE_BORDER := Color("#64757b")
const COLOR_CURSOR := Color("#f2c14e")
const COLOR_MOVE := Color("#5ca37a")
const COLOR_BLOCKED := Color("#342f36")
const COLOR_HERO := Color("#4e83bd")
const COLOR_ENEMY := Color("#b84b4f")

var encounter: CombatEncounter = CombatEncounter.new()
var selected_cell := Vector2i(1, 5)
var awaiting_enemy_turn := false
var battle_finished := false

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
	for diagonal in range(BOARD_SIZE.x + BOARD_SIZE.y - 1):
		for x in range(BOARD_SIZE.x):
			var y := diagonal - x
			if y < 0 or y >= BOARD_SIZE.y:
				continue
			_draw_cell(Vector2i(x, y))

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


func _draw_cell(cell: Vector2i) -> void:
	var center := _grid_to_screen(cell)
	var points := PackedVector2Array([
		center + Vector2(0, -TILE_SIZE.y / 2.0),
		center + Vector2(TILE_SIZE.x / 2.0, 0),
		center + Vector2(0, TILE_SIZE.y / 2.0),
		center + Vector2(-TILE_SIZE.x / 2.0, 0),
	])
	var color := COLOR_TILE_LIGHT if (cell.x + cell.y) % 2 == 0 else COLOR_TILE_DARK
	if cell in BLOCKED_CELLS:
		color = COLOR_BLOCKED
	elif _is_reachable_from_hero(cell):
		color = color.lerp(COLOR_MOVE, 0.35)
	if cell == selected_cell:
		color = color.lerp(COLOR_CURSOR, 0.5)
	draw_colored_polygon(points, color)
	draw_polyline(points + PackedVector2Array([points[0]]), COLOR_TILE_BORDER, 1.5)

	if cell in BLOCKED_CELLS:
		var top := center - Vector2(0, 18)
		draw_colored_polygon(
			PackedVector2Array([
				top + Vector2(0, -22),
				top + Vector2(23, -10),
				top + Vector2(0, 2),
				top + Vector2(-23, -10),
			]),
			Color("#605668")
		)
		draw_colored_polygon(
			PackedVector2Array([
				top + Vector2(-23, -10),
				top + Vector2(0, 2),
				center,
				center + Vector2(-23, -12),
			]),
			Color("#403a47")
		)


func _draw_unit(unit: TacticalUnit) -> void:
	var base := _grid_to_screen(unit.grid_position)
	var color := COLOR_HERO if unit.team == CombatEncounter.TEAM_HERO else COLOR_ENEMY
	draw_circle(base - Vector2(0, 23), 15, color)
	draw_rect(Rect2(base.x - 13, base.y - 24, 26, 29), color)
	draw_circle(base - Vector2(5, 28), 2.5, Color.WHITE)
	draw_circle(base + Vector2(5, -28), 2.5, Color.WHITE)
	draw_line(base + Vector2(-15, 8), base + Vector2(15, 8), Color("#10131a"), 5)

	var hp_ratio := float(unit.hp) / float(unit.max_hp)
	draw_rect(Rect2(base.x - 20, base.y + 12, 40, 5), Color("#151820"))
	draw_rect(Rect2(base.x - 20, base.y + 12, 40 * hp_ratio, 5), Color("#61b86b"))


func _gui_input(event: InputEvent) -> void:
	if battle_finished or awaiting_enemy_turn:
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
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

	if encounter.move_unit(hero, selected_cell, BLOCKED_CELLS):
		_add_log(
			tr("COMBAT_HERO_MOVED") % hero.movement_left
		)
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
				encounter.move_unit(enemy, step, BLOCKED_CELLS)
				_add_log(
					tr("COMBAT_ENEMY_MOVED") % tr(enemy.display_name)
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
		if _is_inside_board(candidate) and encounter.can_move(enemy, candidate, BLOCKED_CELLS):
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
	return encounter.can_move(hero, cell, BLOCKED_CELLS)


func _grid_to_screen(cell: Vector2i) -> Vector2:
	return BOARD_ORIGIN + Vector2(
		(cell.x - cell.y) * TILE_SIZE.x / 2.0,
		(cell.x + cell.y) * TILE_SIZE.y / 2.0
	)


func _screen_to_grid(screen_position: Vector2) -> Vector2i:
	var local := screen_position - BOARD_ORIGIN
	var grid_x := (local.x / (TILE_SIZE.x / 2.0) + local.y / (TILE_SIZE.y / 2.0)) / 2.0
	var grid_y := (local.y / (TILE_SIZE.y / 2.0) - local.x / (TILE_SIZE.x / 2.0)) / 2.0
	return Vector2i(roundi(grid_x), roundi(grid_y))


func _is_inside_board(cell: Vector2i) -> bool:
	return cell.x >= 0 and cell.y >= 0 and cell.x < BOARD_SIZE.x and cell.y < BOARD_SIZE.y
