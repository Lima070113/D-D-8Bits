extends Node

var campaign: Dictionary = {}
var locale := "pt_BR"


func start_campaign(campaign_data: Dictionary, selected_locale: String) -> void:
	campaign = campaign_data.duplicate(true)
	locale = selected_locale
	TranslationServer.set_locale(locale)


func has_campaign() -> bool:
	return not campaign.is_empty()


func reset() -> void:
	campaign.clear()
