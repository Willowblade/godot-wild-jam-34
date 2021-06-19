extends Weapon
class_name ProjectileShooter


var speed = 0
var reload = 0
var lifetime = 0


onready var shoot_timeout = $ShootTimeout

const PROJECTILES = {
	"energy": preload("res://src/game/weapons/projectiles/EnergyProjectile.tscn"),
	"kinetic": preload("res://src/game/weapons/projectiles/KineticProjectile.tscn"),
}

var can_fire = true


func _ready():
	shoot_timeout.connect("timeout", self, "_on_shoot_timeout")

	shoot_distance_min = stats.get("minimum_shoot_distance", 90.0)
	shoot_distance_max = stats.get("maximum_shoot_distance", stats.speed * stats.lifetime)
	speed = stats.speed
	reload = stats.reload
	lifetime = stats.lifetime


func _on_shoot_timeout():
	can_fire = true

func shoot():
	if not can_fire:
		return

	can_fire = false
	shoot_timeout.wait_time = reload
	shoot_timeout.start()

	var projectile_scene_instance = PROJECTILES[shot].instance()
	projectile_scene_instance.load_stats(stats)
	projectile_scene_instance.position = global_position
	projectile_scene_instance.rotation = global_rotation
	projectile_scene_instance.direction = Vector2.UP.rotated(global_rotation)
	GameFlow.projectiles_spawner.shoot_projectile(projectile_scene_instance)

