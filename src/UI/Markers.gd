extends Node2D

var markers = {}

var MarkerScene = preload("res://src/UI/Marker.tscn")


var destination_marker = null

func _ready():
	pass


func get_marker_type(destination):
	if GameFlow.is_station(destination):
		return "station"
	elif GameFlow.is_planet(destination):
		return destination.planet_name


func add_marker(player, destination):
	var marker_instance = MarkerScene.instance()
	add_child(marker_instance)
	marker_instance.visible = false
	marker_instance.player = player
	marker_instance.destination = destination
	marker_instance.set_process(false)
	return marker_instance

func make_markers(player, destinations):
	for destination in destinations:
		if not destination in markers:
			var marker_instance = add_marker(player, destination)
			marker_instance.set_marker(get_marker_type(destination))
			markers[destination] = marker_instance

	if destination_marker == null:
		destination_marker = add_marker(player, null)

func set_destination_marker(destination):
	destination_marker.destination = destination
	destination_marker.visible = true
	destination_marker.set_process(true)

func clear_destination_marker():
	destination_marker.destination = null
	destination_marker.visible = false
	destination_marker.set_process(false)

func update_visible_destinations(destinations):
	print("updating visible destinations ", destinations)
	for destination in markers:
		if destination in destinations:
			markers[destination].set_process(true)
			markers[destination].visible = true
		else:
			markers[destination].visible = false
			markers[destination].set_process(false)

func set_player(player):
	for marker in markers.values():
		marker.player = player




