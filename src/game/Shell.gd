extends Area2D

export var shell_name = "armada"
onready var collision_shape = $CollisionShape2D


func _ready():
	connect("body_entered", self, "_on_body_entered")
	connect("body_exited", self, "_on_body_exited")



func _on_body_entered(body):
	if GameFlow.is_player(body):
		body.swappable_shell = shell_name



func _on_body_exited(body):
	if GameFlow.is_player(body):
		body.swappable_shell = null

