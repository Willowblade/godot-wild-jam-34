extends Ship
class_name Player


onready var origin = position

var destinations = []

export var shell_name = "default"

var carrying = null

func _ready():
	refresh_stats()

	$MarkerRecognition.connect("area_entered", self, "_on_area_entered_marker_area")
	$MarkerRecognition.connect("area_exited", self, "_on_area_exited_marker_area")

	faction = "player"

	mass = 100


func _on_area_entered_marker_area(area):
	print("area entered", area)
	if GameFlow.is_planet(area) or GameFlow.is_station(area):
		destinations.append(area)

		GameFlow.markers.make_markers(self, destinations)
		GameFlow.markers.update_visible_destinations(destinations)

func _on_area_exited_marker_area(area):
	if GameFlow.is_planet(area) or GameFlow.is_station(area):
		if area in destinations:
			destinations.erase(area)

		GameFlow.markers.make_markers(self, destinations)
		GameFlow.markers.update_visible_destinations(destinations)



func refresh_stats():
	var player_stats = Flow.get_player_stats(shell_name)
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


func _physics_process(delta):
	update_shields(delta)
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
