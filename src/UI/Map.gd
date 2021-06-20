extends Node2D


onready var objective_box = $ObjectiveBox
onready var objective_text = $ObjectiveBox/Objective


const MARKERS = {
	"earth": preload("res://assets/graphics/ui/markers/Navigation_Earthlike.png"),
	"blue": preload("res://assets/graphics/ui/markers/Navigation_Blue.png"),
	"purple": preload("res://assets/graphics/ui/markers/Navigation_Purple.png"),
	"mars": preload("res://assets/graphics/ui/markers/Navigation_Marslike.png"),
	"eater": preload("res://assets/graphics/ui/markers/Navigation_PlanetEater.png"),
	"sun": preload("res://assets/graphics/ui/markers/Navigation_Sun.png"),
	"sun_small": preload("res://assets/graphics/ui/markers/Navigation_Sun_Small.png"),
	"station": preload("res://assets/graphics/ui/markers/Navigation_Space_Station.png"),
	"mail": preload("res://assets/graphics/ui/markers/Navigation_Mail.png"),
	"mail_small": preload("res://assets/graphics/ui/markers/Navigation_Mail_Small.png"),
	"igps": preload("res://assets/graphics/ui/markers/Navigation_IGPS.png"),
	"destination": preload("res://assets/graphics/ui/markers/Navigation_Flag2.png"),
	"player": preload("res://assets/graphics/container/bubble.png"),
}


var planets = []
var stations = []
var player = null
var player_marker = null
var destination = null

export var map_scale = 20

var markers = {}

var dimensions = Vector2(960, 540)


func initialize_objects():
	planets = get_tree().get_nodes_in_group("planet")
	stations = get_tree().get_nodes_in_group("station")

	print(planets)
	print(stations)

	for planet in planets:
		var sprite = Sprite.new()
		add_child(sprite)
		sprite.texture = MARKERS[planet.planet_name]
		markers[planet] = sprite

	for station in stations:
		var sprite = Sprite.new()
		add_child(sprite)
		sprite.texture = MARKERS["station"]
		markers[station] = sprite

	var sprite = Sprite.new()
	add_child(sprite)
	sprite.texture = MARKERS["sun"]
	markers[GameFlow.sun] = sprite

	sprite = Sprite.new()
	add_child(sprite)
	sprite.texture = MARKERS["igps"]
	markers[GameFlow.igps] = sprite

func set_player(_player):
	player = _player
	if player_marker == null:
		player_marker = Sprite.new()
		add_child(player_marker)
		player_marker.texture = MARKERS["player"]

func set_destination(_destination):
	if _destination == null:
		if destination != null:
			markers[destination].texture = MARKERS["station"]
	else:
		markers[_destination].texture = MARKERS["mail"]
	destination = _destination

func _ready():
	set_process(false)
	visible = false

func turn_on():
	visible = true
	set_process(true)

func turn_off():
	visible = false
	set_process(false)


func _process(delta):
	if GameFlow.objective:
		objective_box.show()
		objective_text.text = GameFlow.objective
	else:
		objective_box.hide()


	set_player(GameFlow.player)
	set_destination(GameFlow.destination)
	if player == null:
		return

	for object in markers:
		var marker = markers[object]
		var position_difference = object.position - player.position
		marker.position = position_difference / map_scale

	player_marker.position = Vector2()


func _physics_process(delta):
	if Input.is_action_just_pressed("switch"):
		if not visible:
			AudioEngine.play_effect("ui_positive" + str(1 + (randi() % 5)))
			turn_on()
		else:
			AudioEngine.play_effect("ui_negative" + str(1 + (randi() % 4)))
			turn_off()
