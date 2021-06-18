extends Node2D
class_name Emitter

onready var children = get_children()


var emitting = false setget set_emitting

export var one_shot = false

var lifetime = 0.0


func _ready():
	visible = true

	for child in get_children():
		if child is CollisionShape2D:
			continue
		if child.lifetime > lifetime:
			lifetime = child.lifetime
		child.set_emitting(false)

func set_emitting(new_value: bool):
	emitting = new_value

	for child in children:
		if child is CollisionShape2D:
			continue
		child.one_shot = one_shot
		child.set_emitting(emitting)
