extends Node2D


var player = null
var destination = null

const markers = {
	"earth": preload("res://assets/graphics/ui/markers2.png"),
	"mars": preload("res://assets/graphics/ui/markers3.png"),
	"destination": preload("res://assets/graphics/ui/markers1.png"),
	"home": preload("res://assets/graphics/ui/markers4.png"),
	"station": preload("res://assets/graphics/ui/markers4.png")
}

const width = 960.0 - 16
const height = 540.0 - 16

func set_position(direction: Vector2):
	var angle = direction.angle_to(Vector2.RIGHT)
	var radius = Vector2(width / 2, height / 2).length()
	var point_on_circle = direction * radius
	var scale_factor = 1
	if abs(point_on_circle.x) > width / 2:
		scale_factor = width / 2 / abs(point_on_circle.x)
	elif abs(point_on_circle.x) > height / 2:
		scale_factor = height / 2 / abs(point_on_circle.y)
	var point_on_nav = point_on_circle * scale_factor
	position = point_on_nav + Vector2(width / 2, height / 2) + Vector2(8, 8)

func set_marker_destination():
	pass


func set_marker(marker_type):
	$Marked.texture = markers[marker_type]

func _process(delta):
	if destination == null or player == null:
		return
	if destination.position.distance_to(player.position) < 500:
		visible = false
	else:
		visible = true
	set_position((destination.position - player.position).normalized())
	$Marked.rotation = -rotation

func _ready():
	pass
