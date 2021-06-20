extends Reference
class_name PlayerState

var level := 1
var experience := 0
var location := {
	"position": Vector2(0, 0),
	"angle": 0.0,
}
var shell = "armada"
var conditions = []

var context : Dictionary setget set_context, get_context
func set_context(value : Dictionary) -> void:
	level = value.get("level", 1)
	experience = value.get("experience", 0)
	location = value.get("location", {
		"position": Vector2(0, 0),
	})
	conditions = value.get("conditions", [])
	shell = value.get("shell", "armada")
	print("Loaded player context ", value)

func get_context() -> Dictionary:
	var _context := {}

	_context.level = level
	_context.experience = experience
	_context.location = location
	_context.conditions = conditions
	_context.shell = shell

	print("Getting player context ", _context)

	return _context

func get_player_level_effect(level_index: int) -> Dictionary:
	return {
		"max_health": int(6 * (1 + float(level_index) / 3)),
		"max_stamina": int(4 * (1 + float(level_index) / 2)),
		"strength": 0.1,
		"defense": +0.08
	}

func add_condition(condition: String):
	if conditions.has(condition):
		return
	conditions.append(condition)

func has_condition(condition: String):
	return conditions.has(condition)

func get_level(experience_calc: int):
	if experience_calc > 600:
		return 9
	elif experience_calc > 470:
		return 8
	elif experience_calc > 350:
		return 7
	elif experience_calc > 250:
		return 6
	elif experience_calc > 170:
		return 5
	elif experience_calc > 100:
		return 4
	elif experience_calc > 50:
		return 3
	elif experience_calc > 20:
		return 2
	return 1

func get_level_effects() -> Array:
	var actual_level = get_level(experience)
	var upgrades = []
	for i in range(1, actual_level):
		upgrades.append({
			"name": "playerlevel" + str(i),
			"effects": get_player_level_effect(i)
		})
	return upgrades

func get_stats() -> Dictionary:
	var stats: Dictionary = get_base_stats().duplicate(true)
	for upgrade in State.upgrades:
		var upgrade_effects = Flow.get_upgrade_value(upgrade.id, "effects", {})
		var effect = upgrade_effects
		for key in effect:
			stats[key] += effect[key]

	for level_effect in get_level_effects():
		var effect = level_effect.effects
		for key in effect.keys():
			stats[key] += effect[key]

	return stats

var base_stats : Dictionary setget , get_base_stats
func get_base_stats():
	return Flow.get_player_value("base_stats", PLAYER_BASE_STATS)

const PLAYER_BASE_STATS := {

}
