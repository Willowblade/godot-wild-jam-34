extends RigidBody2D
class_name Asteroid


var physics_body = null
var position_to_update = null

export var orbit_speed = 1.0

export var health = 40



signal died

func _ready():
	connect("body_entered", self, "_on_body_entered")

	var direct_state = Physics2DServer.body_get_direct_state(get_rid())
	var new_position = (position - GameFlow.sun_position).rotated(GameFlow.get_time_around_sun() * 2 * PI * orbit_speed) + GameFlow.sun_position
	direct_state.transform.origin = new_position
	print(new_position)

	rotation = randf() * 2 * PI


func calculate_damage(first_collider, second_collider):
	var first_velocity = first_collider.velocity
	var first_mass = first_collider.collider.mass
	var second_velocity = second_collider.velocity
	var second_mass = second_collider.collider.mass
	return (first_velocity - second_velocity).length() * max(first_mass, second_mass) / min(first_mass, second_mass)


func take_damage(damage: int):
	health -= damage
	if health <= 0:
		$Sprite.visible = false
		$Explosion.emitting = true
		collision_layer = 0
		collision_mask = 0
		emit_signal("died", self)
		yield(get_tree().create_timer($Explosion.lifetime - 0.1), "timeout")
		queue_free()

func _on_body_entered(body):
	if GameFlow.is_player(body) or GameFlow.is_enemy(body):
		if GameFlow.is_player(body):
			print("Collided with a player")
		else:
			print("Collided with an enemy")
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

		if done_damage > 4:
			if GameFlow.is_enemy(body):
				body.take_damage(3 * done_damage)
			else:
				body.take_damage(done_damage)
			take_damage(int(float(done_damage) / 10))

		body.handle_rigidbody_collision({
			"collider": self,
			"collider_velocity": direct_state.linear_velocity,
			"position": test_motion_result.collision_point,
		}, 1.0 / 60)



func update_position(updated_position: Vector2):
	position_to_update = updated_position
	set_physics_process(true)


func _physics_process(delta):
	if position_to_update:
		var direct_state = Physics2DServer.body_get_direct_state(get_rid())
		direct_state.transform.origin = position_to_update
		pass
	set_physics_process(false)
