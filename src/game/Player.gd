extends Ship
class_name Player


onready var cannons = $Cannons.get_children()


signal shoot


onready var origin = position


func _ready():
	refresh_stats()


func refresh_stats():
	var player_stats = State.player.get_stats()
	load_stats(player_stats)
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
			if shot_result.target:
				shot_result.target.take_damage(10)
			emit_signal("shoot", shot_result)
			return

func _physics_process(delta):
	var acceleration_boost = 1.0
	next_acceleration_state = "NONE"
	if Input.is_action_pressed("sprint"):
		next_acceleration_state = "BOOST"
		acceleration_boost = boost_power

	if Input.is_action_pressed("accelerate"):
		accelerate(delta, acceleration_boost)
		if next_acceleration_state == "NONE":
			next_acceleration_state = "NORMAL"
	else:
		if next_acceleration_state == "BOOST":
			next_acceleration_state = "NONE"

	if Input.is_action_pressed("decelerate"):
		brake(delta)

	if Input.is_action_pressed("turn_left"):
		turn_left(delta)
		$TurnLeftEmission.emitting = true
	else:
		$TurnLeftEmission.emitting = false

	if Input.is_action_pressed("turn_right"):
		turn_right(delta)
		$TurnRightEmission.emitting = true
	else:
		$TurnRightEmission.emitting = false

	if Input.is_action_pressed("shoot"):
		shoot()

	if velocity.length() > max_speed:
		velocity = velocity.normalized() * max_speed

	update_acceleration_animation()

	var collision: KinematicCollision2D = move_and_collide(velocity * delta, false, true, true)
	move_and_collide(velocity * delta, true)
	handle_rigidbody_collision(collision, delta)


#		velocity -= collision * delta * brake_speed
#	position += velocity * delta
