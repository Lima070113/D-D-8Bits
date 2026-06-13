extends Control

const CampaignSeed = preload("res://src/simulation/campaign/campaign_seed.gd")

var seed_service := CampaignSeed.new()
var selected_locale := "pt_BR"

var title_label: Label
var subtitle_label: Label
var seed_input: LineEdit
var status_label: Label
var create_button: Button
var language_button: Button


func _ready() -> void:
	_build_interface()
	_apply_locale()


func _build_interface() -> void:
	var background := ColorRect.new()
	background.color = Color("#0b0d12")
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(background)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 64)
	margin.add_theme_constant_override("margin_top", 48)
	margin.add_theme_constant_override("margin_right", 64)
	margin.add_theme_constant_override("margin_bottom", 48)
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(margin)

	var layout := VBoxContainer.new()
	layout.alignment = BoxContainer.ALIGNMENT_CENTER
	layout.add_theme_constant_override("separation", 22)
	margin.add_child(layout)

	var eyebrow := Label.new()
	eyebrow.text = "A PROCEDURAL FANTASY RPG"
	eyebrow.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	eyebrow.add_theme_color_override("font_color", Color("#c89945"))
	eyebrow.add_theme_font_size_override("font_size", 16)
	layout.add_child(eyebrow)

	title_label = Label.new()
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.add_theme_color_override("font_color", Color("#f0d594"))
	title_label.add_theme_font_size_override("font_size", 54)
	layout.add_child(title_label)

	subtitle_label = Label.new()
	subtitle_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	subtitle_label.custom_minimum_size = Vector2(0, 70)
	subtitle_label.add_theme_color_override("font_color", Color("#aeb5c3"))
	subtitle_label.add_theme_font_size_override("font_size", 20)
	layout.add_child(subtitle_label)

	var card := VBoxContainer.new()
	card.custom_minimum_size = Vector2(620, 0)
	card.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	card.add_theme_constant_override("separation", 14)
	layout.add_child(card)

	seed_input = LineEdit.new()
	seed_input.placeholder_text = "Seed"
	seed_input.alignment = HORIZONTAL_ALIGNMENT_CENTER
	seed_input.add_theme_font_size_override("font_size", 20)
	card.add_child(seed_input)

	create_button = Button.new()
	create_button.custom_minimum_size = Vector2(0, 56)
	create_button.add_theme_font_size_override("font_size", 18)
	create_button.pressed.connect(_on_create_campaign)
	card.add_child(create_button)

	language_button = Button.new()
	language_button.flat = true
	language_button.pressed.connect(_toggle_language)
	card.add_child(language_button)

	status_label = Label.new()
	status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	status_label.custom_minimum_size = Vector2(0, 60)
	status_label.add_theme_color_override("font_color", Color("#71c49a"))
	layout.add_child(status_label)

	var version := Label.new()
	version.text = "FOUNDATION BUILD 0.1.0"
	version.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	version.add_theme_color_override("font_color", Color("#606979"))
	layout.add_child(version)


func _apply_locale() -> void:
	TranslationServer.set_locale(selected_locale)
	var portuguese := selected_locale == "pt_BR"
	title_label.text = "D&D 8BITS"
	subtitle_label.text = (
		"Cada campanha cria um mundo, uma historia e um legado unicos."
		if portuguese
		else "Every campaign creates a unique world, history, and legacy."
	)
	create_button.text = "CRIAR NOVA CAMPANHA" if portuguese else "CREATE NEW CAMPAIGN"
	language_button.text = "English" if portuguese else "Portugues"
	status_label.text = (
		"Insira uma seed ou deixe em branco para descobrir um novo mundo."
		if portuguese
		else "Enter a seed or leave it blank to discover a new world."
	)


func _toggle_language() -> void:
	selected_locale = "en" if selected_locale == "pt_BR" else "pt_BR"
	_apply_locale()


func _on_create_campaign() -> void:
	var campaign := seed_service.create_campaign_seed(seed_input.text)
	seed_input.text = campaign.display_seed

	if selected_locale == "pt_BR":
		status_label.text = (
			"Mundo criado: %s | assinatura: %s"
			% [campaign.display_seed, campaign.world_signature]
		)
	else:
		status_label.text = (
			"World created: %s | signature: %s"
			% [campaign.display_seed, campaign.world_signature]
		)
