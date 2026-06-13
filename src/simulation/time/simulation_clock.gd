class_name SimulationClock
extends RefCounted

signal time_advanced(minutes: int)

const MINUTES_PER_HOUR := 60
const HOURS_PER_DAY := 24

var total_minutes := 0
var paused := false


func advance(minutes: int) -> void:
	if paused or minutes <= 0:
		return

	total_minutes += minutes
	time_advanced.emit(minutes)


func get_day() -> int:
	return floori(
		total_minutes / float(MINUTES_PER_HOUR * HOURS_PER_DAY)
	) + 1


func get_hour() -> int:
	return floori(total_minutes / float(MINUTES_PER_HOUR)) % HOURS_PER_DAY


func get_minute() -> int:
	return total_minutes % MINUTES_PER_HOUR


func serialize() -> Dictionary:
	return {
		"total_minutes": total_minutes,
		"paused": paused,
	}


func restore(data: Dictionary) -> void:
	total_minutes = maxi(0, int(data.get("total_minutes", 0)))
	paused = bool(data.get("paused", false))
