extends Node2D


onready var unlock = $Unlock
onready var shell = $Shell

export var type = "armada"
export var quantity = 15

var current = -1

func _ready():
	$Shell.shell_name = type

	if State.get_material_amount(type) > quantity:
		unlock()
	else:
		lock()

func unlock():
	set_physics_process(false)
	$Unlock.visible = false
	$Shell.visible = true
	$Shell.collision_shape.disabled = false


func lock():
	set_physics_process(true)
	$Unlock.visible = true
	$Shell.visible = false
	$Shell.collision_shape.disabled = true
	var amount = State.get_material_amount(type)
	$Unlock/Quantity.text = str(quantity - amount)


func _physics_process(true):
	var amount = State.get_material_amount(type)
	if amount >= quantity:
		unlock()
	else:
		if amount != current:
			$Unlock/Quantity.text = str(quantity - amount)
			current = amount

