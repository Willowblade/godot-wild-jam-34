extends Node2D

onready var projectiles = $Projectiles
onready var player = $Player
onready var speed_lines = $SpeedLines

var previous_velocity = Vector2(0, 0)


func _ready():
	player.connect("shoot", projectiles, "_on_projectile_fired")


func _process(delta):
	var velocity = player.velocity
	if velocity.length() > 450:
		speed_lines.visible = true
		speed_lines.spawn_speedline(player)
	# intention here is that we can see if the velocity still changes (player is turning/accelerating at lower speeds, will turn off)
	elif velocity.length() > 100 and velocity.normalized() == previous_velocity.normalized():
		print("equal velocity")
		speed_lines.visible = true
		speed_lines.spawn_speedline(player)
	else:
		speed_lines.visible = false

	previous_velocity = velocity

