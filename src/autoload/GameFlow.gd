extends Node

var overlays = {

}

var hit_emitter = null

var projectiles_spawner = null


var sun_position = Vector2(-4300, 2500)

func register_overlay(overlay_name, overlay: Control):
	overlays[overlay_name] = overlay


func _ready():
	pass


func date_to_day_percentage():
	var universe_start = 1623756429 #  == 15/06/2021 13:28  -> completion of this feature
	var now = OS.get_unix_time()
	return float(abs(now - universe_start)) / 86400


func get_time_around_sun():
	return date_to_day_percentage()


func register_hit_emitter(new_hit_emitter):
	hit_emitter = new_hit_emitter


func register_projectiles_spawner(new_projectiles_spawner):
	projectiles_spawner = new_projectiles_spawner


func is_ship(body):
	return body is Ship


func is_player(body):
	return body is Player


func is_enemy(body):
	return body is Enemy


func is_asteroid(body):
	return body is Asteroid


func is_container(body):
	return body is CargoContainer
