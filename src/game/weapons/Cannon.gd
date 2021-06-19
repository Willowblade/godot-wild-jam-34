extends Weapon
class_name Cannon


var distance = 0
var reload = 0


func _ready():
	distance = stats.distance
	shoot_distance_min = stats.get("minimum_shoot_distance", 80.0)
	shoot_distance_max = stats.get("maximum_shoot_distance", stats.distance)
	reload = stats.reload
