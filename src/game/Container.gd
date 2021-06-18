extends RigidBody2D
class_name CargoContainer

onready var pickup_area = $PickupArea

var destination = null

var tethered = false setget set_tethered

var player = null

func set_tethered(new_tethered):
	tethered = new_tethered
	$TetherVisuals.visible = new_tethered


signal tether(container)



func _ready():
	connect("body_entered", self, "_on_body_entered")
	pickup_area.connect("body_entered", self, "_on_body_entered_pickup")
	set_tethered(false)
	set_physics_process(false)


func _on_body_entered_pickup(body):
	if GameFlow.is_player(body):
		if tethered:
			return
		else:
			print("Emitting tether with ", self)
			player = body
			set_physics_process(true)
			emit_signal("tether", self)
			set_tethered(true)


func _physics_process(delta):
	var segments = $TetherVisuals/LineSegments.get_children()
	var curve = Curve2D.new()
	var direction_away_from_player = Vector2(0, 1).rotated(player.rotation)
	curve.add_point(player.position + 32 * direction_away_from_player, Vector2(0, 0), 64 * direction_away_from_player)
	curve.add_point(position)
	var baked_points = curve.tessellate(4)

	var start_point = player.position
	var i = 0
	for segment in segments:
		segment.visible = false

	for point in baked_points:
		if i >= segments.size():
			continue
		if start_point == position:
			continue
		var segment = segments[i]
		segment.visible = true
		segment.position = ((start_point + point) / 2 - position).rotated(-rotation)
		segment.rotation = Vector2(0, -1).angle_to(point - start_point)  - rotation
		segment.scale = Vector2(1, start_point.distance_to(point) / 16.0)
		start_point = point
		i += 1



func calculate_damage(first_collider, second_collider):
	var first_velocity = first_collider.velocity
	var first_mass = first_collider.collider.mass
	var second_velocity = second_collider.velocity
	var second_mass = second_collider.collider.mass
	return (first_velocity - second_velocity).length() * max(first_mass, second_mass) / min(first_mass, second_mass)


func _on_body_entered(body):
	if GameFlow.is_enemy(body):
		print("Container collided with an enemy")
		var direct_state = Physics2DServer.body_get_direct_state(get_rid())

		var test_motion_result = Physics2DTestMotionResult.new()

		test_motion(body.position - position, true, 0.08, test_motion_result)

		GameFlow.hit_emitter.spawn_hit(test_motion_result.collision_point)

		var damage = calculate_damage({
			"collider": self,
			"velocity": direct_state.linear_velocity,
			"collision_point": test_motion_result.collision_point,
		}, {
			"collider": body,
			"velocity": body.velocity
		})

		var done_damage = 2 * sqrt(max(damage - 4, 0))

		if done_damage > 2:
			body.take_damage(3 * done_damage)
			take_damage(int(float(done_damage) / 10))

		body.handle_rigidbody_collision({
			"collider": self,
			"collider_velocity": direct_state.linear_velocity,
			"position": test_motion_result.collision_point,
		}, 1.0 / 60)
	elif GameFlow.is_asteroid(body):
		var direct_state = Physics2DServer.body_get_direct_state(get_rid())
		var test_motion_result = Physics2DTestMotionResult.new()
		test_motion(body.position - position, true, 0.08, test_motion_result)
		GameFlow.hit_emitter.spawn_hit(test_motion_result.collision_point)


func take_damage(damage: int):
	# Container doesn't take damage? Or does it? Mmm...
	pass

