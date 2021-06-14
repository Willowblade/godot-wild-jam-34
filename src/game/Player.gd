extends Ship
class_name Player


var velocity: Vector2 = Vector2(0, 0)


var acceleration: float = 0.0
var brake_speed: float = 0.0
var turn_speed: float = 0.0
var max_speed: float = 0.0
var boost_power: float = 0.0

var previous_acceleration_state = "NONE"
var next_acceleration_state = "NONE"

onready var cannons = $Cannons.get_children()


var stats = {

}

signal shoot


func _ready():
	refresh_stats()



func refresh_stats():
	var player_stats = State.player.get_stats()
	stats.health = player_stats.max_health
	stats.shields = player_stats.max_shields
	acceleration = player_stats.acceleration
	brake_speed = player_stats.brake_speed
	turn_speed = player_stats.turn_speed
	max_speed = player_stats.max_speed
	boost_power = player_stats.boost_power
#	emit_signal("updated_stats", stats)


func update_acceleration_animation():
	# TODO Use one trail but change properties -> might be  more elegant approach to
	# properly swap between different trails.
	if next_acceleration_state == "NONE":
		AudioEngine.stop_thruster()
		$NormalEmission.emitting = false
		$BoostEmission.emitting = false
	elif next_acceleration_state == "NORMAL":
#		AudioEngine.play_thruster("thrusters", false)
		AudioEngine.play_thruster("jet", false)
		$NormalEmission.emitting = true
		$BoostEmission.emitting = false
	elif next_acceleration_state == "BOOST":
		AudioEngine.play_thruster("jet", true)
		$NormalEmission.emitting = false
		$BoostEmission.emitting = true

	previous_acceleration_state = next_acceleration_state


func shoot():
	for cannon in cannons:
		var shot_result = cannon.shoot()
		if shot_result != null:
			emit_signal("shoot", shot_result)
			return

func _physics_process(delta):
	var orientation = Vector2(0, -1).rotated(rotation)
	var acceleration_boost = 1.0
	next_acceleration_state = "NONE"
	if Input.is_action_pressed("sprint"):
		next_acceleration_state = "BOOST"
		acceleration_boost = boost_power

	if Input.is_action_pressed("accelerate"):
		velocity += delta * orientation * acceleration * acceleration_boost
		if next_acceleration_state == "NONE":
			next_acceleration_state = "NORMAL"
		if velocity.length() > max_speed:
			velocity = velocity.normalized() * max_speed
	else:
		if next_acceleration_state == "BOOST":
			next_acceleration_state = "NONE"

	if Input.is_action_pressed("decelerate"):
		velocity -= velocity * delta * brake_speed
		if next_acceleration_state != "NONE":
			next_acceleration_state = "NONE"

	if Input.is_action_pressed("turn_left"):
		rotation -= turn_speed * delta
		$TurnLeftEmission.emitting = true
	else:
		$TurnLeftEmission.emitting = false

	if Input.is_action_pressed("turn_right"):
		rotation += turn_speed * delta
		$TurnRightEmission.emitting = true
	else:
		$TurnRightEmission.emitting = false

	if Input.is_action_pressed("shoot"):
		shoot()

	update_acceleration_animation()

	move_and_collide(velocity * delta)
#	position += velocity * delta
