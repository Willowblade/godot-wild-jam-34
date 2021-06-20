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
	"home": "res://assets/audio/music/home.ogg",
	"explore": "res://assets/audio/music/explore.ogg",
	"battle": "res://assets/audio/music/battle.ogg",
	"flight": "res://assets/audio/music/flight.ogg",
}

const sfx = {
	"jet": "res://assets/audio/sfx/jet_loop.ogg",
	"thrusters": "res://assets/audio/sfx/thrusters_loop.ogg",
	"boost": "res://assets/audio/sfx/boost_loop_start_3s.ogg",
	"explosion_small1": "res://assets/audio/sfx/explosions/GWJ_34_Explosions_Small-001.ogg",
	"explosion_small2": "res://assets/audio/sfx/explosions/GWJ_34_Explosions_Small-002.ogg",
	"explosion_small3": "res://assets/audio/sfx/explosions/GWJ_34_Explosions_Small-003.ogg",
	"explosion_small4": "res://assets/audio/sfx/explosions/GWJ_34_Explosions_Small-004.ogg",
	"explosion_smaller1": "res://assets/audio/sfx/explosions/GWJ_34_Explosions_Smaller-001.ogg",
	"explosion_smaller2": "res://assets/audio/sfx/explosions/GWJ_34_Explosions_Smaller-002.ogg",
	"heat_release": "res://assets/audio/sfx/ui/GWJ_34_PlayerShip_HeatRelease.ogg",
	"hull_hit1": "res://assets/audio/sfx/ui/GWJ_34_PlayerShip_Hit_Hull-001.ogg",
	"hull_hit2": "res://assets/audio/sfx/ui/GWJ_34_PlayerShip_Hit_Hull-002.ogg",
	"hull_hit3": "res://assets/audio/sfx/ui/GWJ_34_PlayerShip_Hit_Hull-003.ogg",
	"hull_hit4": "res://assets/audio/sfx/ui/GWJ_34_PlayerShip_Hit_Hull-004.ogg",
	"hull_hit5": "res://assets/audio/sfx/ui/GWJ_34_PlayerShip_Hit_Hull-005.ogg",
	"shield_hit1": "res://assets/audio/sfx/ui/GWJ_34_PlayerShip_Hit_Shield-001.ogg",
	"shield_hit2": "res://assets/audio/sfx/ui/GWJ_34_PlayerShip_Hit_Shield-002.ogg",
	"shield_hit3": "res://assets/audio/sfx/ui/GWJ_34_PlayerShip_Hit_Shield-003.ogg",
	"shield_hit4": "res://assets/audio/sfx/ui/GWJ_34_PlayerShip_Hit_Shield-004.ogg",
	"shield_hit5": "res://assets/audio/sfx/ui/GWJ_34_PlayerShip_Hit_Shield-005.ogg",
	"repair1": "res://assets/audio/sfx/ui/GWJ_34_PlayerShip_Repair-001.ogg",
	"repair2": "res://assets/audio/sfx/ui/GWJ_34_PlayerShip_Repair-002.ogg",
	"repair3": "res://assets/audio/sfx/ui/GWJ_34_PlayerShip_Repair-003.ogg",
	"repair4": "res://assets/audio/sfx/ui/GWJ_34_PlayerShip_Repair-004.ogg",
	"repair5": "res://assets/audio/sfx/ui/GWJ_34_PlayerShip_Repair-005.ogg",
	"warning1": "res://assets/audio/sfx/ui/GWJ_34_PlayerShip_Warnings-001.ogg",
	"warning2": "res://assets/audio/sfx/ui/GWJ_34_PlayerShip_Warnings-002.ogg",
	"warning3": "res://assets/audio/sfx/ui/GWJ_34_PlayerShip_Warnings-003.ogg",
	"warning4": "res://assets/audio/sfx/ui/GWJ_34_PlayerShip_Warnings-004.ogg",
	"warning5": "res://assets/audio/sfx/ui/GWJ_34_PlayerShip_Warnings-005.ogg",
	"warning6": "res://assets/audio/sfx/ui/GWJ_34_PlayerShip_Warnings-006.ogg",
	"ui_negative1": "res://assets/audio/sfx/ui/GWJ_34_UI_Negative-001.ogg",
	"ui_negative2": "res://assets/audio/sfx/ui/GWJ_34_UI_Negative-002.ogg",
	"ui_negative3": "res://assets/audio/sfx/ui/GWJ_34_UI_Negative-003.ogg",
	"ui_negative4": "res://assets/audio/sfx/ui/GWJ_34_UI_Negative-004.ogg",
	"ui_positive1": "res://assets/audio/sfx/ui/GWJ_34_UI_Positive-001.ogg",
	"ui_positive2": "res://assets/audio/sfx/ui/GWJ_34_UI_Positive-002.ogg",
	"ui_positive3": "res://assets/audio/sfx/ui/GWJ_34_UI_Positive-003.ogg",
	"ui_positive4": "res://assets/audio/sfx/ui/GWJ_34_UI_Positive-004.ogg",
	"ui_positive5": "res://assets/audio/sfx/ui/GWJ_34_UI_Positive-005.ogg",

	"weapon_cannon1": "res://assets/audio/sfx/ui/GWJ_34_Weapon_Cannon-001.ogg",
	"weapon_cannon2": "res://assets/audio/sfx/ui/GWJ_34_Weapon_Cannon-002.ogg",
	"weapon_cannon3": "res://assets/audio/sfx/ui/GWJ_34_Weapon_Cannon-003.ogg",
	"weapon_cannon4": "res://assets/audio/sfx/ui/GWJ_34_Weapon_Cannon-004.ogg",

	"weapon_thiccbeam1": "res://assets/audio/sfx/ui/GWJ_34_Weapon_ThiccBeam-001.ogg",
	"weapon_thiccbeam2": "res://assets/audio/sfx/ui/GWJ_34_Weapon_ThiccBeam-002.ogg",
	"weapon_thiccbeam3": "res://assets/audio/sfx/ui/GWJ_34_Weapon_ThiccBeam-003.ogg",
	"weapon_thiccbeam4": "res://assets/audio/sfx/ui/GWJ_34_Weapon_ThiccBeam-004.ogg",

	"weapon_projectile": "res://assets/audio/sfx/ui/GWJ_34_Weapon_MachineGun_Oneshotwav.ogg",
	"weapon_rocket": "res://assets/audio/sfx/ui/GWJ_34_Weapon_Rocket.ogg",
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
