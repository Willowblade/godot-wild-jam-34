extends Cannon
class_name DirectCannon

onready var shoot_timeout = $ShootTimeout
onready var raycast = $RayCast

export var TIMEOUT = 0.3
export var DISTANCE = 300

var can_fire = true

func _ready():
	shoot_timeout.connect("timeout", self, "_on_shoot_timeout")
	raycast.cast_to = Vector2(0, -DISTANCE)


func _on_shoot_timeout():
	can_fire = true


func shoot():
	if not can_fire:
		return

	can_fire = false
	shoot_timeout.wait_time = TIMEOUT
	shoot_timeout.start()


	return {
		"type": "RAILGUN",
		"properties": {
			"distance": DISTANCE,
		},
		"source": self,
		"target": raycast.get_collider(),
	}

