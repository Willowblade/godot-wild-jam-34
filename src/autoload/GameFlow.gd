extends Node

var overlays = {

}

var hit_emitter = null

var projectiles_spawner = null

var markers = null

var map = null

var canvas = null

var sun_position = Vector2(-4300, 2500)

func register_overlay(overlay_name, overlay):
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


func register_markers(new_markers):
	markers = new_markers


func register_projectiles_spawner(new_projectiles_spawner):
	projectiles_spawner = new_projectiles_spawner


func register_map(new_map):
	map = new_map


func register_canvas(new_canvas):
	canvas = new_canvas


func is_ship(body):
	return body is Ship


func is_player(body):
	return body is Player


func is_enemy(body):
	return body is Enemy


func is_asteroid(body):
	return body is Asteroid


func is_rocket(body):
	return body is Rocket


func is_container(body):
	return body is CargoContainer

func is_planet(body):
	return body is Planet


func is_station(body):
	return body is Station


var player = null
var player_shell = "default"
var followers = []
var in_igps = false
var stations_in_proximity = []
var player_mindframe = "EXPLORE"

var igps = null
var sun = null

var objective = null

var destination = null


func reset():
	objective = null
	player = null
	player_shell = "default"
	followers = []
	in_igps = false
	stations_in_proximity = []
	player_mindframe = "EXPLORE"

func update_player(new_player):
	player = new_player
	player.connect("died", self, "_on_player_dead")


func _on_player_dead(_player):
	if Flow._game_state == Flow.STATE.GAME:
		Flow.go_to_game()
	else:
		Flow.go_to_tutorial()


func is_in_battle():
	return player_mindframe == "BATTLE"

func add_follower(ship):
	if ship in followers:
		return
	followers.append(ship)
	if followers.size() == 1:
		player_mindframe = "BATTLE"
		AudioEngine.play_background_music("battle")

func set_player_mindframe(new_mindframe):
	player_mindframe = new_mindframe
	AudioEngine.play_background_music(new_mindframe.to_lower())

func remove_follower(ship):
	if not ship in followers:
		return
	followers.erase(ship)
	if followers.size() == 0:
		if stations_in_proximity.size() > 0:
			set_player_mindframe("HOME")
		else:
			set_player_mindframe("EXPLORE")


func add_station(station):
	if station in stations_in_proximity:
		return
	stations_in_proximity.append(station)
	if stations_in_proximity.size() == 1:
		if player_mindframe != "BATTLE":
			set_player_mindframe("HOME")


func remove_station(station):
	if not station in stations_in_proximity:
		return
	stations_in_proximity.erase(station)
	if player_mindframe == "HOME":
		set_player_mindframe("EXPLORE")


func enter_igps():
	in_igps = true

func exit_igps():
	in_igps = false


func deliver_package():
	State.player.delivered_packets.append(destination.station_name)
	State.upgrades.post += 1
	Flow.save_game()
	GameFlow.objective = canvas.comeback_message
	GameFlow.overlays.popup.show_popup_custom(GameFlow.objective, Vector2(0, 40), "info", 3)
	destination = null
	canvas.spawn_container_with_destination(canvas.station_map[canvas.get_container_destination()])
