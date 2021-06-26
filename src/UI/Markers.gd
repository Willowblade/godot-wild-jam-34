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
	marker_instance.destination = destination
	marker_instance.set_process(false)
	return marker_instance


func make_markers(player, destinations):
	if not GameFlow.sun in markers:
		var marker_instance = add_marker(player, GameFlow.sun)
		marker_instance.set_marker("sun")
		markers[GameFlow.sun] = marker_instance
		marker_instance.visible = true
		marker_instance.set_process(true)

	if not GameFlow.igps in markers:
		var marker_instance = add_marker(player, GameFlow.igps)
		marker_instance.set_marker("igps")
		markers[GameFlow.igps] = marker_instance
		marker_instance.visible = true
		marker_instance.set_process(true)

	for destination in destinations:
		if not destination in markers:
			var marker_instance = add_marker(player, destination)
			marker_instance.set_marker(get_marker_type(destination))
			markers[destination] = marker_instance

	if destination_marker == null:
		destination_marker = add_marker(player, null)


func set_destination_marker(destination):
	destination_marker.destination = destination
	destination_marker.set_marker("mail_flag")
	destination_marker.visible = true
	destination_marker.set_process(true)
	destination_marker.z_index = 1


func clear_destination_marker():
	destination_marker.destination = null
	destination_marker.visible = false
	destination_marker.set_process(false)


func _process(delta):
	# TODO this should also be signal driven...
	if GameFlow.destination:
		set_destination_marker(GameFlow.destination)
	else:
		clear_destination_marker()


func update_visible_destinations(destinations):
	for destination in markers:
		if destination == GameFlow.sun:
			continue

		if destination == GameFlow.igps:
			continue

		if destination in destinations:
			markers[destination].set_process(true)
			markers[destination].visible = true
		else:
			markers[destination].visible = false
			markers[destination].set_process(false)
