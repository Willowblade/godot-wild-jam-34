extends RigidBody2D


var physics_body = null
var position_to_update = null

export var orbit_speed = 0.9

func _ready():
	connect("body_entered", self, "_on_body_entered")
	connect("sleeping_state_changed", self, "_on_sleeping_state_changed")

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

func _on_sleeping_state_changed():
	print("Sleeping state changed")

func update_position(updated_position: Vector2):
	position_to_update = updated_position
	set_physics_process(true)

func _physics_process(delta):
	if position_to_update:
		var direct_state = Physics2DServer.body_get_direct_state(get_rid())
		direct_state.transform.origin = position_to_update
		pass
	set_physics_process(false)
