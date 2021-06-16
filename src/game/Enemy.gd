extends Ship
class_name Enemy

export var faction = "Armada"

onready var detection_area = $DetectionArea
onready var notify_area = $NotifyArea

onready var raycast = $Raycast

var notifiers = []

var origin = null
var state = "IDLE"
# state = "CHASE"
var target = null
var target_position = null


var investigation_timeout = 0.0

func load_generic_enemy_stats():
	load_stats({
		"max_health": 50,
		"max_shields": 10,
		"acceleration": 150,
		"brake_speed": 1.5,
		"turn_speed": 1,
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
	if body is Player:
		if target == null:
			print("Player entered detection area")
			set_physics_process(true)
			state = "CHASE"
			target = body

func _on_body_exited_detection_area(body: PhysicsBody2D):
	if body is Player:
		print("Enemy ship of same faction exited detection area")
		# could have been dead
		if body != null:
			switch_to_investigate()
			target = null
			target_position = body.position


func _on_body_entered_notify_area(body: PhysicsBody2D):
	if body is Ship and not body is Player and body.faction == faction:
		print("Enemy ship of same faction entered notification area")
		notifiers.append(body)


func _on_body_exited_notify_area(body: PhysicsBody2D):
	if body in notifiers:
		print("Enemy ship of same faction exited notification area")
		notifiers.erase(body)


func turn_towards_target(delta):
	var orientation = get_orientation()
	var target_orientation: Vector2 = target_position - position
	var angle = target_orientation.angle_to(orientation)
	if angle > 0 and angle < PI:
		turn_left(delta)
		$TurnLeftEmission.emitting = true
		$TurnRightEmission.emitting = false
	elif angle < 0 and angle > -PI:
		turn_right(delta)
		$TurnLeftEmission.emitting = false
		$TurnRightEmission.emitting = true

func move_towards_target(delta):
	var orientation = get_orientation()
	var target_orientation: Vector2 = target_position - position
	var angle_to_target = target_orientation.angle_to(orientation)
	if abs(angle_to_target) < PI / 2:
		accelerate(delta)
		$NormalEmission.emitting = true
	else:
		brake(delta)
		$NormalEmission.emitting = false


func _physics_process(delta):
	$Debug.text = state
	$Target.text = str(target)
	if state == "IDLE":
		target_position = origin
		turn_towards_target(delta)
		if position.distance_to(origin) < 100:
			if velocity.length() > 0:
				print("Braking!!")
				brake(delta)
			else:
				# can go to idle when no need for movement
				print("Going idle close to target")
				set_physics_process(false)
		else:
			move_towards_target(delta)


	if state == "CHASE":
		target_position = target.position
		turn_towards_target(delta)

		print((target_position - position).rotated(-rotation))
		raycast.cast_to = (target_position - position).rotated(-rotation)

		raycast.force_raycast_update()
		var collider = raycast.get_collider()

		if collider != null:
			if not collider is Player:
				print("Seeing ", collider, OS.get_unix_time())
				# TODO was here adding collider logic for shooting asteroids
			else:
				print("Seeing player")
		if position.distance_to(target_position) < 200 and position.distance_to(target_position) > 100:
			brake(delta)
		else:
			move_towards_target(delta)

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
