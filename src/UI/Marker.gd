extends Node2D

var destination = null


var _marker_type = ""

const markers = {
	"earth": preload("res://assets/graphics/ui/markers/Navigation_Earthlike.png"),
	"blue": preload("res://assets/graphics/ui/markers/Navigation_Blue.png"),
	"purple": preload("res://assets/graphics/ui/markers/Navigation_Purple.png"),
	"mars": preload("res://assets/graphics/ui/markers/Navigation_Marslike.png"),
	"eater": preload("res://assets/graphics/ui/markers/Navigation_PlanetEater.png"),
	"sun": preload("res://assets/graphics/ui/markers/Navigation_Sun.png"),
	"sun_small": preload("res://assets/graphics/ui/markers/Navigation_Sun_Small.png"),
	"station": preload("res://assets/graphics/ui/markers/Navigation_Space_Station.png"),
	"mail": preload("res://assets/graphics/ui/markers/Navigation_Mail.png"),
	"mail_flag": preload("res://assets/graphics/ui/markers/Navigation_Mail_Flag.png"),
	"mail_small": preload("res://assets/graphics/ui/markers/Navigation_Mail_Small.png"),
	"igps": preload("res://assets/graphics/ui/markers/Navigation_IGPS.png"),
	"destination": preload("res://assets/graphics/ui/markers/Navigation_Flag2.png"),
}

const width = 960.0 - 16
const height = 540.0 - 16


func set_position(direction: Vector2):

	var angle = direction.angle_to(Vector2.RIGHT)

	var radius = Vector2(width / 2, height / 2).length()
	var point_on_circle = direction * radius
	var scale_factor = 1
	if abs(point_on_circle.x) > (width / 2):
		scale_factor = width / 2 / abs(point_on_circle.x)
	elif abs(point_on_circle.y) > (height / 2):
		scale_factor = height / 2 / abs(point_on_circle.y)
	var point_on_nav = point_on_circle * scale_factor

	position = point_on_nav + Vector2(width / 2, height / 2) + Vector2(8, 8)


func set_marker_destination():
	pass


func set_marker(marker_type):
	_marker_type = marker_type
	$Marked.texture = markers[_marker_type]


func _process(delta):
	var player = GameFlow.player
	if destination == null or player == null:
		return
	if destination.position.distance_to(player.position) < 300:
		$Marked.visible = false
	else:
		$Marked.visible = true
	set_position((destination.position - player.position).normalized())
	$Marked.rotation = -rotation

func _ready():
	pass
