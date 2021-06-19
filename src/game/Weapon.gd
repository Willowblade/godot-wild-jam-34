extends Node2D
class_name Weapon

export(String) var weapon_name = ""

var faction = ""

var stats = {}

var shooter = null

var type = ""
var shot = ""
var damage = ""
var shield_multiplier = 1.0
var hull_multiplier = 1.0

var shoot_distance_min = 120.0
var shoot_distance_max = 200.0


func is_within_shooting_distance(distance: float):
	return distance >= shoot_distance_min and distance <= shoot_distance_max

func _ready():
	stats = Flow.get_weapon_stats(weapon_name)
	type = stats.type
	shot = stats.shot
	damage = stats.damage
	shield_multiplier = stats.get("shield_multiplier", 1.0)
	hull_multiplier = stats.get("hull_multiplier", 1.0)
