extends Ship
class_name Enemy

onready var detection_area = $DetectionArea
onready var notify_area = $NotifyArea

onready var raycast = $Raycast

var notifiers = []

var origin = null
var state = "IDLE"
# state = "CHASE"
var target = null
var target_position = null


var targets = []


var investigation_timeout = 0.0

func load_generic_enemy_stats():
	load_stats({
		"max_health": 50,
		"max_shields": 10,
		"acceleration": 150,
		"brake_speed": 1.5,
		"turn_speed": 1.5,
		"max_speed": 200,
		"boost_power": 2,
	})


func _ready():
	origin = position

	load_generic_enemy_stats()

	detection_area.connect("body_entered", self, "_on_body_entered_detection_area")
	detection_area.connect("body_exited", self, "_on_body_exited_detection_area")
	notify_area.connect("body_entered", self, "_on_body_entered_notify_area")
	notify_area.connect("body_exited", self, "_on_body_exited_notify_area")
	randomize()
	rotation = randf() * 2 * PI


func switch_to_investigate():
	investigation_timeout = 0.0
	state = "INVESTIGATE"

func _on_body_entered_detection_area(body: PhysicsBody2D):
	if GameFlow.is_ship(body) and body.faction != faction:
		targets.append(body)
		if target == null:
			set_physics_process(true)
			state = "CHASE"
			target = body

func _on_body_exited_detection_area(body: PhysicsBody2D):
	if GameFlow.is_ship(body) and body.faction != faction:
		targets.erase(body)
		# could have been dead
		if targets.size() > 0:
			target = targets[0]
		else:
			if body != null:
				switch_to_investigate()
				target = null
				target_position = body.position


func _on_body_entered_notify_area(body: PhysicsBody2D):
	if GameFlow.is_ship(body) and body.faction == faction:
		print("Enemy ship of same faction entered notification area")
		notifiers.append(body)


func _on_body_exited_notify_area(body: PhysicsBody2D):
	if body in notifiers:
		print("Enemy ship of same faction exited notification area")
		notifiers.erase(body)


func turn_towards_target(delta):
	var angle_to_target = get_angle_to_target()
	if angle_to_target > 0 and angle_to_target < PI:
		turn_left(delta)
		$TurnLeftEmission.emitting = true
		$TurnRightEmission.emitting = false
	elif angle_to_target < 0 and angle_to_target > -PI:
		turn_right(delta)
		$TurnLeftEmission.emitting = false
		$TurnRightEmission.emitting = true

func get_angle_to_target():
	var orientation = get_orientation()
	var target_orientation: Vector2 = target_position - position
	var angle = target_orientation.angle_to(orientation)
	return angle

func move_towards_target(delta):
	var angle_to_target = get_angle_to_target()

	if abs(angle_to_target) < PI / 3:
		accelerate(delta)
		$NormalEmission.emitting = true
	else:
		brake(delta)
		$NormalEmission.emitting = false


func _physics_process(delta):
	update_shields(delta)
	$Debug.text = state
	$Target.text = str(target)
	if state == "IDLE":
		target_position = origin
		turn_towards_target(delta)
		if position.distance_to(origin) < 100:
			if velocity.length() > 0:
				brake(delta)
			else:
				# can go to idle when no need for movement
				print("Going idle close to target")
				set_physics_process(false)
				# heal shields back to full
				stats.shields = stats.max_shields
		else:
			move_towards_target(delta)


	if state == "CHASE":
		target_position = target.position
		var distance = position.distance_to(target_position)

		raycast.cast_to = (target_position - position).rotated(-rotation)

		raycast.force_raycast_update()
		var collider = raycast.get_collider()

		if collider != null:
			if not collider is Player:
				# print("Seeing ", collider, OS.get_unix_time())
				pass
				# TODO was here adding collider logic for shooting asteroids
			else:
				# print("Seeing player")
				pass


		if distance > minimum_shooting_distance and distance < maximum_shooting_distance:
			turn_towards_target(delta)
			brake(delta)
		elif distance > maximum_shooting_distance:
			turn_towards_target(delta)
			move_towards_target(delta)
		else:
			target_position = position + Vector2.UP.rotated(rotation) * minimum_shooting_distance
			move_towards_target(delta)

		# todo be able to check weapon range here...
		if distance > minimum_shooting_distance and distance < maximum_shooting_distance:
			if abs(get_angle_to_target()) < PI / 8:
				var eligible_weapons = weapons_safe_for_shooting(distance)
				shoot(eligible_weapons)

	if state == "INVESTIGATE":
		turn_towards_target(delta)
		if position.distance_to(target_position) < 100:
			brake(delta)
		else:
			move_towards_target(delta)
		investigation_timeout += delta
		if investigation_timeout > 5:
			state = "IDLE"

	if velocity.length() > max_speed:
		velocity = velocity.normalized() * max_speed

	var collision: KinematicCollision2D = move_and_collide(velocity * delta, false, true, true)
	move_and_collide(velocity * delta, true)
	handle_rigidbody_collision(collision, delta)
