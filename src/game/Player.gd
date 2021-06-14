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

var weight = 10

var colliding_steps = 0


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

	if Input.is_action_pressed("strafe_right"):
		velocity += Vector2(100, 0).rotated(rotation) * delta
		$StrafeRightEmission.emitting = true
	else:
		$StrafeRightEmission.emitting = false

	if Input.is_action_pressed("strafe_left"):
		velocity -= Vector2(100, 0).rotated(rotation) * delta
		$StrafeLeftEmission.emitting = true
	else:
		$StrafeLeftEmission.emitting = false

	if velocity.length() > max_speed:
		velocity = velocity.normalized() * max_speed

	update_acceleration_animation()

	var collision: KinematicCollision2D = move_and_collide(velocity * delta, false, true, true)
	move_and_collide(velocity * delta, true)
	if collision != null and colliding_steps == 0:
		var collider: RigidBody2D = collision.collider
		var collider_velocity = collision.collider_velocity
		var speed_difference = velocity - collider_velocity
		var force = Vector2()
		var force_collider = Vector2()
		if sign(velocity.x) == sign(collider_velocity.x):
			if speed_difference.x > 0:
				force.x = weight * speed_difference.x
			elif speed_difference.x < 0:
				force_collider.x  = collider.weight * speed_difference.x
		else:
			force.x = weight * velocity.x
			force_collider.x  = collider.weight * collider_velocity.x
		if sign(velocity.y) == sign(collider_velocity.y):
			if speed_difference.y > 0:
				force.y = weight * speed_difference.y
			elif speed_difference.y < 0:
				force_collider.y  = collider.weight * speed_difference.y
		else:
			force.y = weight * velocity.y
			force_collider.y = collider.weight * collider_velocity.y

		var delta_v = (force_collider - force) / weight * delta
		var impulse = (force - force_collider) * delta

#		velocity = velocity + (force_collider - force) * delta * delta * 0.5 / weight * collider.weight
#		velocity = velocity + (force_collider * weight - force * collider.weight) * delta * delta * 0.5 / weight
#		collider.apply_impulse(Vector2(0, 0), (force * collider.weight - force_collider * weight) * delta * delta * 0.5 / collider.weight * weight)

		velocity = velocity + delta_v
		collider.apply_impulse(Vector2(0, 0), impulse * weight / collider.weight)

		colliding_steps += 1
	else:
		colliding_steps = 0

		#		var force = weight * velocity / delta
		#		var force_collider = collider.weight * collider_velocity / delta
		#		var force_total = force + force_collider
		#
		#		velocity = velocity + (force_collider - force) * delta * delta * collider.weight / weight
		#		collider.apply_impulse(Vector2(0, 0), (force - force_collider) * delta * delta * 0.2 * weight / collider.weight)


#		velocity -= collision * delta * brake_speed
#	position += velocity * delta
