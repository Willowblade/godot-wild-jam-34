# State is an autoload script that contains all global state variables.
extends Node

var _upgrade_resource := preload("res://src/autoload/state/Upgrade.gd")
var _player_resource := preload("res://src/autoload/state/Player.gd")

### GLOBAL CONSTANTS ##########################################################

## STATE ######################################################################

func load_state_from_context(context : Dictionary):
	print_debug("Loading state from the context...")

	player = null
	upgrades = null

	add_materials_from_context(context.get("upgrades", {}))

	add_player_from_context(context.get("player", {}))


func save_state_to_context() -> Dictionary:
	var context := {}

	var context_dict := {
		"player": player.context,
		"upgrades": upgrades.context,
	}

	context["player"] = player.context
	context["upgrades"] = upgrades.context

	return context


## PLAYERS ####################################################################
var player: PlayerState = null

func add_player_from_context(player_context : Dictionary) -> void:
	player = _player_resource.new()
	player.context = player_context


## UPGRADES ####################################################################
var upgrades: UpgradeState = null

func add_material(material_type: String, amount: int) -> void:
	if material_type in upgrades:
		upgrades[material_type] += amount
	else:
		upgrades[material_type] = amount


func get_material_amount(material_type: String) -> int:
	return upgrades.context.get(material_type, 0)

func add_materials_from_context(upgrade_context : Dictionary) -> void:
	upgrades = _upgrade_resource.new()
	upgrades.context = upgrade_context

