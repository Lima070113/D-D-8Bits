class_name CampaignSeed
extends RefCounted

const ALPHABET := "ABCDEFGHJKLMNPQRSTUVWXYZ23456789"
const GENERATED_SEED_LENGTH := 12


func create_campaign_seed(requested_seed: String) -> Dictionary:
	var display_seed := requested_seed.strip_edges().to_upper()
	if display_seed.is_empty():
		display_seed = _generate_readable_seed()

	var numeric_seed := hash(display_seed)
	var world_signature := "%08X" % (numeric_seed & 0xFFFFFFFF)

	return {
		"display_seed": display_seed,
		"numeric_seed": numeric_seed,
		"world_signature": world_signature,
	}


func _generate_readable_seed() -> String:
	var random := RandomNumberGenerator.new()
	random.randomize()
	var characters: Array[String] = []

	for index in GENERATED_SEED_LENGTH:
		if index > 0 and index % 4 == 0:
			characters.append("-")
		characters.append(ALPHABET[random.randi_range(0, ALPHABET.length() - 1)])

	return "".join(characters)
