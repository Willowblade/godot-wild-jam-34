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
}

const sfx = {
	"shoot": "res://assets/audio/sfx/shoot.ogg",
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

func reset():
#	effects.reset()
	stop_background_music()
	
func play_ambiance():
	ambiance_player.play()

func stop_ambiance():
	ambiance_player.stop()

func play_background_music():
	"""TODODODODODOD"""

func stop_background_music():
	"""Stops the background music track"""
	if background_player.playing:
		background_player.stop()
		background_audio = null		

