extends Node2D


const MARKERS = {
	"earth": preload("res://assets/graphics/ui/markers2.png"),
	"mars": preload("res://assets/graphics/ui/markers3.png"),
	"sun": preload("res://assets/graphics/ui/markers3.png"),
	"destination": preload("res://assets/graphics/ui/markers1.png"),
	"home": preload("res://assets/graphics/ui/markers4.png"),
	"player": preload("res://assets/graphics/ui/markers2.png"),
	"station": preload("res://assets/graphics/ui/markers4.png")
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

func set_player(_player):
	print("Setting player", _player)
	player = _player
	if player_marker == null:
		player_marker = Sprite.new()
		add_child(player_marker)
		player_marker.texture = MARKERS["player"]

func set_destination(_destination):
	destination = _destination
	if destination == null:
		markers[destination].texture = MARKERS["station"]
	else:
		markers[destination].texture = MARKERS["destination"]

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
	if player == null:
		return

	for object in markers:
		var marker = markers[object]
		var position_difference = object.position - player.position
		marker.position = position_difference / map_scale

	player_marker.position = Vector2()

func _physics_process(delta):
	if Input.is_action_just_pressed("switch"):
		print("Switch pressed!")
		if not visible:
			turn_on()
		else:
			turn_off()
