extends Node2D

onready var health_bar = $Health
onready var heat_bar = $Heat
onready var shield_bar = $Shield

func _ready():
	GameFlow.register_overlay("hud", self)


func update_stats(stats):
	set_heat(min(max(stats.heat, 0), 1.0))
	set_shields(min(max(stats.shield, 0), 1.0))
	set_health(min(max(stats.health, 0), 1.0))

var timer = 0.0
var full_region_height = 100
var start_offset = 22


func set_heat(heat):
	heat_bar.position = Vector2(80, 466) + (1.0 - heat) * Vector2(0, 100)
	heat_bar.region_rect.size.y = 100 * heat
	heat_bar.region_rect.position.y = 22 + 100 * (1.0 - heat)
	heat_bar.modulate = Color(1.0, 1.0 - heat, 0, 1)
	if heat == 1.0:
		$CPUParticles2D.emitting = true
	else:
		$CPUParticles2D.emitting = false


func set_health(health):
	health_bar.position = Vector2(80, 466) + (1.0 - health) * Vector2(0, 100)
	health_bar.region_rect.size.y = 100 * health
	health_bar.region_rect.position.y = 22 + 100 * (1.0 - health)


func set_shields(shields):
	shield_bar.position = Vector2(80, 466) + (1.0 - shields) * Vector2(0, 100)
	shield_bar.region_rect.size.y = 100 * shields
	shield_bar.region_rect.position.y = 22 + 100 * (1.0 - shields)


#func _process(delta):
#	timer += delta
#	set_heat(timer / 5)
#
#	set_health(timer / 5)
#	set_shields(timer / 5)
