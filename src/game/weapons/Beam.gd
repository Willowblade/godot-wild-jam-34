extends Weapon
class_name Beam

onready var raycast: RayCast2D = $RayCast

var distance = 0
onready var damage_tick_timeout = $DamageTickTimeout


var can_damage = true

const BEAMS = {
	"default": preload("res://src/game/weapons/projectiles/EnergyProjectile.tscn"),
}

func _ready():
	damage_tick_timeout.connect("timeout", self, "_on_damage_tick_timeout")

	distance = stats.distance
	shoot_distance_min = stats.get("minimum_shoot_distance", 40.0)
	shoot_distance_max = stats.get("maximum_shoot_distance", stats.distance)
	raycast.cast_to = Vector2(0, -distance)

func _on_damage_tick_timeout():
	can_damage = true

func shoot():
	var target = raycast.get_collider()
	if target:
		if can_damage:
			target.take_damage(damage)
			can_damage = false
			damage_tick_timeout.wait_time = 0.1
			damage_tick_timeout.start()

	return {
		"type": type,
		"shot": shot,
		"properties": {
			"distance": distance,
		},
		"source": self,
		"target": target,
		"hit_point": raycast.get_collision_point(),
	}
