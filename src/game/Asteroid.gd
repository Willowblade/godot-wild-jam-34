extends RigidBody2D


var physics_body = null
var position_to_update = null

export var orbit_speed = 0.9

func _ready():
	pass

func update_position(updated_position: Vector2):
	position_to_update = updated_position
	set_physics_process(true)

func _physics_process(delta):
	if position_to_update:
		var direct_state = Physics2DServer.body_get_direct_state(get_rid())
		direct_state.transform.origin = position_to_update
		pass
	set_physics_process(false)
