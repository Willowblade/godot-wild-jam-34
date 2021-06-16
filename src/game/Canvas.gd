extends Node2D

onready var projectiles = $Projectiles
onready var player = $Player
onready var speed_lines = $SpeedLines
onready var sun = $Sun

onready var orbitable_nodes = get_tree().get_nodes_in_group("orbitable")
onready var orbitables = {
	"ships": {},
	"stations": {},
	"asteroids": {},
	"normal": {},
}

var previous_velocity = Vector2(0, 0)

var last_timestamp = null

onready var start_time = OS.get_datetime()

func get_orbitable_type(orbitable):
	if orbitable.is_in_group("ships"):
		return "ship"
	elif orbitable.is_in_group("stations"):
		return "station"
	elif orbitable.is_in_group("asteroids"):
		return "asteroid"
	else:
		return "normal"

func _ready():
	player.connect("shoot", projectiles, "_on_projectile_fired")
	AudioEngine.play_background_music("explore")

	for orbitable in orbitable_nodes:
		if get_orbitable_type(orbitable) == "ship":
			orbitables.ships[orbitable] = {
				"distance": sun.position.distance_to(orbitable.position),
				"original_position": orbitable.position
			}
		elif get_orbitable_type(orbitable) == "station":
			orbitables.stations[orbitable] = {
				"distance": sun.position.distance_to(orbitable.position),
				"original_position": orbitable.position
			}
		elif get_orbitable_type(orbitable) == "asteroid":
			orbitables.asteroids[orbitable] = {
				"distance": sun.position.distance_to(orbitable.position),
				"original_position": orbitable.position
			}
		else:
			orbitables.normal[orbitable] = {
				"distance": sun.position.distance_to(orbitable.position),
				"original_position": orbitable.position
			}


	last_timestamp = date_to_day_percentage()
	update_orbitables(true)




func date_to_day_percentage():
	var universe_start = 1623756429 #  == 15/06/2021 13:28  -> completion of this feature
	var now = OS.get_unix_time()
	return abs(now - universe_start) / 86400


func update_orbitables(include_ships = false):
#	return
	for station in orbitables.stations:
		var station_data = orbitables.stations[station]
		station.position = (station_data.original_position - sun.position).rotated(last_timestamp * 2 * PI * station.orbit_speed) + sun.position

	for normal in orbitables.normal:
		var normal_data = orbitables.normal[normal]
		normal.position = (normal_data.original_position - sun.position).rotated(last_timestamp * 2 * PI * normal.orbit_speed) + sun.position
		normal.rotation = last_timestamp * 2 * PI * normal.orbit_speed

	if include_ships:
		for ship in orbitables.ships:
			print("updating ship position?")
			var ship_data = orbitables.ships[ship]
			ship.position = (ship_data.original_position - sun.position).rotated(last_timestamp * 2 * PI) + sun.position
			ship.origin = ship.position

		for asteroid in orbitables.asteroids:
			print("updating asteroid position?")
			var asteroid_data = orbitables.asteroids[asteroid]
			asteroid.update_position((asteroid_data.original_position - sun.position).rotated(last_timestamp * 2 * PI * asteroid.orbit_speed) + sun.position)
#			var updated_position = Physics2DDirectBodyState.new()
#			updated_position.transform = Transform2D(0, (asteroid_data.original_position - sun.position).rotated(last_timestamp * 2 * PI) + sun.position)
#			asteroid._integrate_forces(updated_position)
#			updated_position.integrate_forces()
#			asteroid.position = (asteroid_data.original_position - sun.position).rotated(last_timestamp * 2 * PI) + sun.position



func _physics_process(delta):
	var now = date_to_day_percentage()
	if (now != last_timestamp):
		last_timestamp = now
		update_orbitables(false)



	var velocity = player.velocity
	if velocity.length() > 380:
		speed_lines.visible = true
		speed_lines.spawn_speedline(player)
	# intention here is that we can see if the velocity still changes (player is turning/accelerating at lower speeds, will turn off)
	elif velocity.length() > 100 and velocity.normalized() == previous_velocity.normalized():
		speed_lines.visible = true
		speed_lines.spawn_speedline(player)
	else:
		speed_lines.visible = false

	previous_velocity = velocity

