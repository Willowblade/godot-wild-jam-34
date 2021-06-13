extends Node2D
class_name Projectiles

onready var RailgunBulletScene = preload("res://src/game/bullets/RailgunBullet.tscn")


func _ready():
	pass

func _on_projectile_fired(projectile_data):
	print("Projectile shot!")
	print(projectile_data)
	if projectile_data.type == "RAILGUN":
		shoot_railgun_bullet(projectile_data.get("properties", {}), projectile_data.source, projectile_data.target)


func shoot_railgun_bullet(properties, source: Node2D, target: Node2D):
	var railgun_bullet_instance = RailgunBulletScene.instance()
	add_child(railgun_bullet_instance)
	railgun_bullet_instance.position = source.global_position
	railgun_bullet_instance.rotation = source.global_rotation + PI
	if target == null:
		railgun_bullet_instance.set_size(properties.distance)
	else:
		# for not overshooting targets
		railgun_bullet_instance.set_size(target.global_position.distance_to(source.global_position))

