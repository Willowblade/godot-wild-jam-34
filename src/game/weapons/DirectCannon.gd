extends Cannon
class_name DirectCannon

onready var shoot_timeout = $ShootTimeout
onready var raycast: RayCast2D = $RayCast


var can_fire = true

func _ready():
	shoot_timeout.connect("timeout", self, "_on_shoot_timeout")
	raycast.cast_to = Vector2(0, -distance)


func _on_shoot_timeout():
	can_fire = true


func shoot():
	if not can_fire:
		return

	can_fire = false
	shoot_timeout.wait_time = reload
	shoot_timeout.start()

	var target = raycast.get_collider()
	if target:
		target.take_damage(damage)

	return {
		"type": type,
		"properties": {
			"distance": distance,
		},
		"source": self,
		"target": target,
		"hit_point": raycast.get_collision_point(),
	}

