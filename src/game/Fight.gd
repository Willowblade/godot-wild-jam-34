extends Node2D


func _ready():
	GameFlow.register_hit_emitter($HitEmitter)
	GameFlow.register_projectiles_spawner($Projectiles)


func _process(delta):
	var enemies = get_tree().get_nodes_in_group("enemy")
	var average_position = Vector2()
	for enemy in enemies:
		average_position += enemy.position

	average_position = average_position / enemies.size()
	$Position2D.position = average_position

