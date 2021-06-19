extends Ship
class_name Rocket

var target = null
var target_position = null

var lifetime = 0.0

var time_lived = 0.0
var targets = []


func _ready():
	connect("body_entered", self, "_on_body_entered")
	$DetectionArea.connect("body_entered", self, "_on_target_entered")
	$DetectionArea.connect("body_exited", self, "_on_target_exited")



func _on_target_exited(body: PhysicsBody2D):
	if GameFlow.is_ship(body) and body.faction != faction:
		targets.erase(body)
		# could have been dead
		if targets.size() > 0:
			target = targets[0]
		else:
			target = null

var exploded = false


func _on_target_entered(body):
	if target != null:
		return

	if GameFlow.is_ship(body):
		if body.faction != faction:
			targets.append(body)
			target = body


func get_shot(direction: Vector2):
	velocity = max_speed * direction
	set_physics_process(true)


func load_stats(rocket_stats: Dictionary):
	lifetime = rocket_stats.lifetime
	acceleration = rocket_stats.acceleration
	brake_speed = rocket_stats.get("brake_speed", 2.0)
	turn_speed = rocket_stats.turn_speed
	max_speed = rocket_stats.speed
	stats.health = rocket_stats.health
	stats.max_health = rocket_stats.health
	stats.shields = 0
	stats.max_shields = 0


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

	if abs(angle_to_target) < PI / 9:
		accelerate(delta)
		$NormalEmission.emitting = true
	else:
		brake(delta)
		$NormalEmission.emitting = false

func _on_body_entered(body):
	if GameFlow.is_ship(body) or GameFlow.is_asteroid(body) or GameFlow.is_container(body):
		explode()

func explode():
	if exploded or time_lived < 0.4:
		return
	exploded = true
	play_explosion()
	impact_explosion()
	collision_layer = 0
	collision_mask = 0
	set_physics_process(false)
	yield(get_tree().create_timer(2.0), "timeout")
	get_parent().remove_child(self)
	queue_free()

func _physics_process(delta):
	lifetime -= delta
	time_lived += delta

	if lifetime < 0:
		explode()
		return

	if lifetime < 1.0:
		$NormalEmission.emitting = false
		velocity = min(velocity.length(), max_speed * lifetime / 1.0) * velocity.normalized()
	else:
		if target:
			target_position = target.position + target.velocity * 0.5
			turn_towards_target(delta)
			move_towards_target(delta)

	var collision: KinematicCollision2D = move_and_collide(velocity * delta, true)
	if collision:
		explode()

