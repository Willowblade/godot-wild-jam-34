extends Area2D


func _ready():
	connect("body_entered", self, "_on_body_entered")
	connect("body_exited", self, "_on_body_exited")


func _on_body_entered(body):
	if GameFlow.is_player(body):
		body.sun = self

func _on_body_exited(body):
	if GameFlow.is_player(body):
		body.sun = null

