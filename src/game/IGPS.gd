extends Node2D


onready var player_detection_area = $PlayerDetectionArea
onready var cargo_spawn_point = $CargoSpawnPoint


var healing_tick = 0.5
var healing_tick_timer = 0.0

var player = null

func _ready():
	set_physics_process(false)
	player_detection_area.connect("body_entered", self, "_on_body_entered_player_detection_area")
	player_detection_area.connect("body_exited", self, "_on_body_exited_player_detection_area")


func _on_body_entered_player_detection_area(body):
	if GameFlow.is_player(body):
		player = body
		GameFlow.enter_igps()
		GameFlow.add_station(self)
		set_physics_process(true)
		healing_tick_timer = 0


func _on_body_exited_player_detection_area(body):
	if GameFlow.is_player(body):
		GameFlow.exit_igps()
		GameFlow.remove_station(self)
		set_physics_process(false)


func _physics_process(delta):
	healing_tick_timer += delta
	if healing_tick_timer > healing_tick:
		healing_tick_timer = 0.0
		if not GameFlow.is_in_battle() and player.velocity.length() < 40:
			if player.stats.health < player.stats.max_health:
				AudioEngine.play_effect("repair" + str(1 + (randi() % 5)))
				player.heal(0.1)
