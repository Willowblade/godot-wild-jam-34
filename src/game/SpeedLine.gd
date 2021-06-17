extends Sprite

const FADE_RATE = 2

var velocity = Vector2(0, 0)


func _ready():
	pass

func _process(delta):
	modulate.a = max(0, modulate.a - delta * 1 / FADE_RATE)
	position += velocity / 50
	if self.modulate.a <= 0.2:
		get_parent().remove_child(self)
		queue_free()
