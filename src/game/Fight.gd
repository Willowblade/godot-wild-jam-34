extends Node2D

var pace = false

func _ready():
	GameFlow.register_hit_emitter($HitEmitter)
	GameFlow.register_projectiles_spawner($Projectiles)

	AudioEngine.play_background_music("battle")

	var enemies = get_tree().get_nodes_in_group("enemy")
	for enemy in enemies:
		enemy.connect("died", self, "_on_enemy_died")


func _on_enemy_died(enemy):
	if pace:
		return

	var factions = {}
	var enemies = get_tree().get_nodes_in_group("enemy")
	for enemy in enemies:
		factions[enemy.faction] = 1

	if factions.keys().size() <= 1:
		pace = true
		AudioEngine.play_background_music("home")

func _process(delta):
	var enemies = get_tree().get_nodes_in_group("enemy")
	if enemies.size() == 0:
		set_process(false)

	var average_position = Vector2()
	for enemy in enemies:
		average_position += enemy.position

	average_position = average_position / enemies.size()
	$Position2D.position = average_position

