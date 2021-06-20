extends Area2D


func _ready():
	connect("body_entered", self, "_on_body_entered")
	connect("body_exited", self, "_on_body_exited")


func _on_body_entered(body):
	if GameFlow.is_player(body):
		AudioEngine.play_effect("warning2")
		set_physics_process(true)
		body.sun = self

func _on_body_exited(body):
	if GameFlow.is_player(body):
		body.sun = null
		AudioEngine.play_sun_ambient(false, 0)
		set_physics_process(false)


func _physics_process(delta):
	var player = GameFlow.player
	if player.sun != null:
		var distance = GameFlow.player.position.distance_to(self.position)
		AudioEngine.play_sun_ambient(true, distance)
	else:
		AudioEngine.play_sun_ambient(false, 0)
		set_physics_process(false)

