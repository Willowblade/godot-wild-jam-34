extends Node2D

onready var projectiles = $Projectiles
onready var player = $Player
onready var speed_lines = $SpeedLines
onready var sun = $Sun

var previous_velocity = Vector2(0, 0)

onready var start_time = OS.get_datetime()

func _ready():
	player.connect("shoot", projectiles, "_on_projectile_fired")
	AudioEngine.play_background_music("flight")




func date_to_day_percentage():
	var now = OS.get_unix_time()
	return float(now % 86400) / 86400



func _process(delta):
	var velocity = player.velocity
	if velocity.length() > 380:
		speed_lines.visible = true
		speed_lines.spawn_speedline(player)
	# intention here is that we can see if the velocity still changes (player is turning/accelerating at lower speeds, will turn off)
	elif velocity.length() > 100 and velocity.normalized() == previous_velocity.normalized():
		speed_lines.visible = true
		speed_lines.spawn_speedline(player)
	else:
		speed_lines.visible = false

	previous_velocity = velocity

