extends Node2D

onready var children = get_children()

var emitting = false setget set_emitting

func set_emitting(new_value: bool):
	emitting = new_value

	for child in children:
		child.emitting = emitting


func _ready():
	pass
