extends Node2D


onready var speed_line_texture = preload("res://assets/graphics/ships/trail/speed-line.png")
onready var SpeedLineScene = preload("res://src/game/SpeedLine.tscn")

func _ready():
	pass



func spawn_speedline(player: Player):
	if randf() > 0.05:
		return
	print("Adding speed line")
	var speed_line_instance = SpeedLineScene.instance()
	add_child(speed_line_instance)
	speed_line_instance.global_position = player.global_position + Vector2(randf() * 1000 - 500, randf() * 1000 - 500)
	speed_line_instance.velocity = -player.velocity
	speed_line_instance.scale.y = player.velocity.length() / 80
	speed_line_instance.scale.x = 1.2
	speed_line_instance.rotation = player.velocity.angle() - PI / 2
