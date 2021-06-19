extends Node2D
class_name Projectiles

onready var RailgunBulletScene = preload("res://src/game/weapons/RailgunBullet.tscn")
onready var BeamBulletScene = preload("res://src/game/weapons/BeamBullet.tscn")
onready var HitEffectScene = preload("res://src/game/HitEmitter.tscn")


func _ready():
	pass


func _on_projectile_fired(projectile_data):
	if projectile_data.type == "cannon":
		shoot_railgun_bullet(projectile_data)
	elif projectile_data.type == "beam":
		shoot_beam_bullet(projectile_data)


func fire_projectile(projectile_data):
	if projectile_data.type == "cannon":
		shoot_railgun_bullet(projectile_data)
	elif projectile_data.type == "beam":
		shoot_beam_bullet(projectile_data)


func shoot_railgun_bullet(projectile_data):
	var properties = projectile_data.get("properties", {})
	var source = projectile_data.source
	var target = projectile_data.target
	var railgun_bullet_instance = RailgunBulletScene.instance()
	add_child(railgun_bullet_instance)
	railgun_bullet_instance.position = source.global_position
	railgun_bullet_instance.rotation = source.global_rotation + PI

	if target == null:
		railgun_bullet_instance.set_size(properties.distance)
	else:
		# for not overshooting targets
		railgun_bullet_instance.set_size(projectile_data.hit_point.distance_to(source.global_position))

		GameFlow.hit_emitter.spawn_hit(projectile_data.hit_point)


func shoot_rocket(rocket: Rocket):
	add_child(rocket)


func shoot_projectile(projectile: Projectile):
	projectile.connect("delete", self, "on_projectile_deleted")
	add_child(projectile)


func shoot_beam_bullet(projectile_data):
	var properties = projectile_data.get("properties", {})
	var source = projectile_data.source
	var target = projectile_data.target
	var beam_bullet_instance = BeamBulletScene.instance()
	add_child(beam_bullet_instance)
	beam_bullet_instance.position = source.global_position
	beam_bullet_instance.rotation = source.global_rotation + PI

	if target == null:
		beam_bullet_instance.set_size(properties.distance)
	else:
		# for not overshooting targets
		beam_bullet_instance.set_size(projectile_data.hit_point.distance_to(source.global_position))

		GameFlow.hit_emitter.spawn_hit(projectile_data.hit_point)


func on_projectile_deleted(projectile):
	yield(get_tree().create_timer(0.0), "timeout")
	remove_child(projectile)
	projectile.queue_free()
