extends Weapon
class_name RocketLauncher

onready var shoot_timeout = $ShootTimeout

const ROCKETS = {
	"default": preload("res://src/game/weapons/rockets/RocketMk1.tscn"),
	"big_rocket": preload("res://src/game/weapons/rockets/RocketMk2.tscn"),
	"huge_rocket": preload("res://src/game/weapons/rockets/RocketMk3.tscn"),
}

var can_fire = true

var speed = 0
var acceleration = 0
var turn_speed = 0
var reload = 0



func _ready():
	shoot_distance_min = stats.get("minimum_shoot_distance", 300.0)
	shoot_distance_max = stats.get("maximum_shoot_distance", 500.0)

	shoot_timeout.connect("timeout", self, "_on_shoot_timeout")
	speed = stats.speed
	acceleration = stats.acceleration
	turn_speed = stats.turn_speed
	reload = stats.reload


func _on_shoot_timeout():
	can_fire = true

func shoot():
	if not can_fire:
		return

	can_fire = false
	shoot_timeout.wait_time = reload
	shoot_timeout.start()

	print("Firing rocket!")

	var rocket_scene_instance = ROCKETS[shot].instance()
	rocket_scene_instance.load_stats(stats)
	rocket_scene_instance.position = global_position
	rocket_scene_instance.rotation = global_rotation
	rocket_scene_instance.faction = faction
	rocket_scene_instance.explosion_damage = damage
	rocket_scene_instance.get_shot(Vector2.UP.rotated(global_rotation))
	GameFlow.projectiles_spawner.shoot_rocket(rocket_scene_instance)


