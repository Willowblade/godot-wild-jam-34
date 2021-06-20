extends Node2D


onready var unlock = $Unlock
onready var shell = $Shell

export var type = "armada"
export var quantity = 15

var current = -1

var unlocked = false

const textures = {
	"armada": preload("res://assets/graphics/ships/player/armada.png"),
	"default": preload("res://assets/graphics/ships/player/standard.png"),
	"carrot": preload("res://assets/graphics/ships/player/carrot.png"),
	"rot": preload("res://assets/graphics/ships/player/rot.png"),
	"solreign": preload("res://assets/graphics/ships/player/solreign.png"),
}

func _ready():
	$Shell.shell_name = type

	if State.get_material_amount(type) > quantity:
		unlock()
	else:
		lock()

func update_type(new_type):
	type = new_type
	$Shell.shell_name = new_type
	$Shell/Sprite.texture = textures[new_type]


func unlock():
	unlocked = true
	set_physics_process(true)
	$Unlock.visible = false
	$Shell.visible = true
	$Shell.collision_shape.disabled = false


func lock():
	unlocked = false
	set_physics_process(true)
	$Unlock.visible = true
	$Shell.visible = false
	$Shell.collision_shape.disabled = true
	var amount = State.get_material_amount(type)
	$Unlock/Quantity.text = str(quantity - amount)


func _physics_process(true):
	if unlocked:
		if GameFlow.player.shell_name == type:
			update_type("default")
		return

	var amount = State.get_material_amount(type)

	if amount >= quantity:
		unlock()
	else:
		if amount != current:
			$Unlock/Quantity.text = str(quantity - amount)
			current = amount

