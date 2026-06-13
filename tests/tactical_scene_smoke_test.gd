extends Node


func _ready() -> void:
	GameSession.start_campaign(
		{
			"display_seed": "TEST-SEED",
			"numeric_seed": 12345,
			"world_signature": "00003039",
		},
		"pt_BR"
	)

	var scene := load("res://src/presentation/tactical/TacticalArena.tscn") as PackedScene
	assert(scene != null)
	var arena := scene.instantiate()
	add_child(arena)
	await get_tree().process_frame
	await get_tree().process_frame

	assert(arena.encounter != null)
	assert(arena.encounter.get_hero().hp == 24)
	assert(arena.end_turn_button.text.contains("ENCERRAR"))
	assert(arena.log_label != null)

	print("tactical_scene_smoke_test: PASS")
	get_tree().quit(0)
