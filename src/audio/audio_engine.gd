"""
Audio Engine

"""
extends Node

onready var background_players = {
	"first": $BackgroundPlayer,
	"second": $SecondBackgroundPlayer,
}

var current_background_player = null


const tracks = {
	"main": "res://assets/audio/music/main.ogg",
	"battle": "res://assets/audio/music/battle.ogg",
	"flight": "res://assets/audio/music/flight.ogg",

}

const sfx = {
	"jet": "res://assets/audio/sfx/jet_loop.ogg",
	"thrusters": "res://assets/audio/sfx/thrusters_loop.ogg",
	"boost": "res://assets/audio/sfx/boost_loop_start_3s.ogg"
}


onready var background_player: AudioStreamPlayer = $BackgroundPlayer
onready var ambiance_player: AudioStreamPlayer = $AmbiancePlayer
onready var dialogue_player: AudioStreamPlayer = $DialoguePlayer
onready var effects: Node = $Effects


func convert_scale_to_db(scale: float):
	return 20 * log(scale) / log(10)


var background_audio = null

export var MAX_SIMULTANEOUS_EFFECTS = 5


func _ready():
	#play_background_music("light_rain")
	for _i in range(MAX_SIMULTANEOUS_EFFECTS):
		effects.add_effect()


func play_effect(effect_name: String):
	effects.play_effect(sfx[effect_name])

func play_background_music(track_name: String):
	var track_path = tracks[track_name]
	if background_audio == track_path:
		return

	var background_player = null
	if current_background_player == null:
		current_background_player = background_players.first
		background_audio = track_path
		current_background_player.stream = load(track_path)
		current_background_player.play()
	else:
		if current_background_player == background_players.first:
			$AnimationPlayer.play("switch_2")
			current_background_player = background_players.second
			background_audio = track_path
			current_background_player.stream = load(track_path)
			current_background_player.play()
		elif current_background_player == background_players.second:
			$AnimationPlayer.play("switch_1")
			current_background_player = background_players.first
			background_audio = track_path
			current_background_player.stream = load(track_path)
			current_background_player.play()


func reset():
#	effects.reset()
	stop_background_music()

func play_ambiance():
	ambiance_player.play()

func stop_ambiance():
	ambiance_player.stop()

func stop_background_music():
	"""Stops the background music track"""
	if background_player.playing:
		background_player.stop()
		background_audio = null



var thruster_audio = null

func play_thruster(thruster_type: String, boost: bool):
	var track_path = sfx[thruster_type]
	if boost:
		track_path = sfx["boost"]
	if thruster_audio == track_path:
		return

	thruster_audio = track_path
	$ThrusterPlayer.stream = load(track_path)
	if boost:
		$ThrusterPlayer.stream.loop_offset = 3
	$ThrusterPlayer.play()


func stop_thruster():
	$ThrusterPlayer.stop()
	thruster_audio = null
