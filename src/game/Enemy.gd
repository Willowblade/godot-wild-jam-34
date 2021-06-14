extends Ship
class_name Enemy

export var faction = "Armada"

onready var detection_area = $DetectionArea
onready var notify_area = $NotifyArea

var notifiers = []

func _ready():
	detection_area.connect("body_entered", self, "_on_body_entered_detection_area")
	notify_area.connect("body_entered", self, "_on_body_entered_notify_area")
	notify_area.connect("body_exited", self, "_on_body_exited_notify_area")


func _on_body_entered_detection_area(body: PhysicsBody2D):
	if body is Player:
		print("Player entered detection area")

func _on_body_entered_notify_area(body: PhysicsBody2D):
	if body is Ship and not body is Player and body.faction == faction:
		print("Enemy ship of same faction entered notification area")
		notifiers.append(body)

func _on_body_exited_notify_area(body: PhysicsBody2D):
	if body in notifiers:
		print("Enemy ship of same faction exited notification area")
		notifiers.erase(body)


