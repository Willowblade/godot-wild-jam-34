extends Node2D


const FADE_RATE = 0.4

func _ready():
	pass


func set_size(size: float):
	$End.position = Vector2(-0.5, size)
	scale.x = 1.5
	$Line.scale.y = size



func _process(delta):
	modulate.a = max(0, modulate.a - delta * 1 / FADE_RATE)
	scale.x -= delta * 1 / FADE_RATE / 2
	if self.modulate.a <= 0:
		get_parent().remove_child(self)
		queue_free()
