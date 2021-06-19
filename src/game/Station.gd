extends Area2D
class_name Station

onready var delivery_area = $DeliveryArea
onready var player_detection_area = $PlayerDetectionArea
onready var cargo_spawn_point = $CargoSpawnPoint
onready var cargo_anchor_point = $AnchorPoint

export var station_name = "test"

export var orbit_speed = 1

func _ready():
	delivery_area.connect("body_entered", self, "_on_body_entered_delivery_area")
	delivery_area.connect("body_exited", self, "_on_body_exited_delivery_area")

	player_detection_area.connect("body_entered", self, "_on_body_entered_player_detection_area")
	player_detection_area.connect("body_exited", self, "_on_body_exited_player_detection_area")

func _on_body_entered_delivery_area(body):
	print("Body in delivery area")
	if GameFlow.is_player(body):
		var container = body.carrying
		if container == null:
			return
		if container.destination == station_name:
			container.delivery_station = self
		else:
			delivery_area.modulate = Color(1, 0, 0, 1)
			container.delivery_station = null


func _on_body_exited_delivery_area(body):
	if GameFlow.is_player(body):
		var container = body.carrying
		if container == null:
			return
		delivery_area.modulate = Color(1, 1, 1, 1)
		if not container.delivered:
			container.delivery_station = null


func _on_body_entered_player_detection_area(body):
	if GameFlow.is_player(body):
		GameFlow.add_station(self)


func _on_body_exited_player_detection_area(body):
	if GameFlow.is_player(body):
		GameFlow.remove_station(self)
