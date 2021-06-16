extends Node2D

onready var children = get_children()

var emitting = false setget set_emitting

export var one_shot = false

var lifetime = 0.0


func _ready():
	for child in get_children():
		print(child)
		print(child.lifetime)
		if child.lifetime > lifetime:
			lifetime = child.lifetime
		child.set_emitting(false)

func set_emitting(new_value: bool):
	emitting = new_value

	for child in children:
		child.one_shot = one_shot
		child.set_emitting(emitting)
