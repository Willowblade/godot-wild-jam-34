extends RigidBody2D
class_name CargoContainer

onready var pickup_area = $PickupArea

var destination = "test"

var tethered = false setget set_tethered


var should_move_to_position = null
var player = null

var delivery_station = null

var delivered = false

func set_tethered(new_tethered):
	tethered = new_tethered
	$TetherVisuals.visible = new_tethered


signal tether(container, target)



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
			player.carrying = self
			set_physics_process(true)
			sleeping = false
			emit_signal("tether", self, player)
			set_tethered(true)


func _physics_process(delta):
	var direct_state = Physics2DServer.body_get_direct_state(get_rid())

	if should_move_to_position != null:
		direct_state.transform.origin = should_move_to_position
		should_move_to_position = null
		if !tethered:
			set_physics_process(false)
			return

	if delivery_station != null and not delivered:
		if direct_state.linear_velocity.length() < 1000:
			sleeping = false
			delivered = true
			player.carrying = null
			emit_signal("tether", self, null)
			print("Delivered!!")

	var offset = Vector2.DOWN * 24
	if delivered:
		var distance = (delivery_station.cargo_anchor_point.global_position + 2 * offset - position).length()
		print(distance)
		if distance < 10:
			print("Delivered!!")
			queue_free()


	var segments = $TetherVisuals/LineSegments.get_children()
	var curve = Curve2D.new()
	if delivered:
		curve.add_point(delivery_station.cargo_anchor_point.global_position)
		curve.add_point(delivery_station.cargo_anchor_point.global_position + offset, Vector2(0, 0), 32 * Vector2.DOWN)
	else:
		var direction_away_from_player = Vector2(0, 1).rotated(player.rotation)
		curve.add_point(player.position + 32 * direction_away_from_player, Vector2(0, 0), 64 * direction_away_from_player)
	curve.add_point(position)
	var baked_points = curve.tessellate(4)

	var start_point = player.position
	if delivered:
		start_point = delivery_station.cargo_anchor_point.global_position
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

	if delivered:
		linear_damp = 1.0
		var distance = (delivery_station.cargo_anchor_point.global_position + 2 * offset - position).length()
		if direct_state.linear_velocity.length() < 60:
			print("Applyingn impulse")
			apply_impulse(Vector2(0, 0), (delivery_station.cargo_anchor_point.global_position + 2 * offset - position).normalized() * 4)
		# if abs(direct_state.linear_velocity.angle_to(delivery_station.delivery_area.global_position - position)) >= PI / 2:
		# 	apply_impulse(Vector2(0, 0), (delivery_station.delivery_area.global_position - position) / 10)
		# else:
		# 	apply_impulse(Vector2(0, 0), (position - delivery_station.delivery_area.global_position) / 10)

		# 	if distance < 20:

		# 	apply_impulse(Vector2(0, 0), (delivery_station.delivery_area.global_position - position) / 10)
		# elif distance > 20 and distance < 100:
		# 	pass
		# else:
		# 	apply_impulse(Vector2(0, 0), (position - delivery_station.delivery_area.global_position) / 10)

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
		GameFlow.hit_emitter.spawn_hit(position + (body.position - position).normalized() * 8)


func take_damage(damage: int):
	# Container doesn't take damage? Or does it? Mmm...
	pass

