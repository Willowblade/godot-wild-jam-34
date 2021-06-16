extends RigidBody2D
class_name Asteroid


var physics_body = null
var position_to_update = null

export var orbit_speed = 1.0

export var health = 40

func _ready():
	connect("body_entered", self, "_on_body_entered")

	rotation = randf() * 2 * PI


func take_damage(damage: int):
	health -= damage
	if health <= 0:
		print("I was deleted!")
		$Sprite.visible = false
		$Explosion.emitting = true
		collision_layer = 0
		collision_mask = 0
		yield(get_tree().create_timer($Explosion.lifetime - 0.1), "timeout")
		queue_free()

func _on_body_entered(body):
	if body is Player or body is Enemy:
		if body is Player:
			print("Collided with a player")
		else:
			print("Collided with an enemy")
		var direct_state = Physics2DServer.body_get_direct_state(get_rid())

		print(body.velocity)
		if body.velocity == Vector2(0, 0):
			print({
				"collider": self,
				"velocity": direct_state.linear_velocity,
			}, 1.0 / 60)
			body.handle_rigidbody_collision({
				"collider": self,
				"velocity": direct_state.linear_velocity,
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
