extends Node2D


const FADE_RATE = 2.0 / 60

func _ready():
	pass


func set_size(size: float):
	scale.x = 1.0
	$Line.scale.y = size / 16.0



func _process(delta):
	modulate.a = max(0, modulate.a - delta * 1 / FADE_RATE)
	if self.modulate.a <= 0:
		get_parent().remove_child(self)
		queue_free()
