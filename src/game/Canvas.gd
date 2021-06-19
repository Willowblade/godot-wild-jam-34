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

var last_timestamp = 0


func get_orbitable_type(orbitable):
	if orbitable.is_in_group("ships"):
		return "ship"
	elif orbitable.is_in_group("stations"):
		return "station"
	elif orbitable.is_in_group("asteroids"):
		return "asteroid"
	else:
		return "normal"

func get_orbitable_data(orbitable):
	return {
		"distance": sun.position.distance_to(orbitable.position),
		"original_position": orbitable.position,
		"original_rotation": orbitable.rotation
	}

func _ready():
	GameFlow.register_hit_emitter($HitEmitter)
	GameFlow.register_projectiles_spawner($Projectiles)
	AudioEngine.play_background_music("explore")

	GameFlow.player = player

	$Container.connect("tether", self, "_on_container_tethered")

	for orbitable in orbitable_nodes:
		if get_orbitable_type(orbitable) == "ship":
			orbitables.ships[orbitable] = get_orbitable_data(orbitable)
		elif get_orbitable_type(orbitable) == "station":
			orbitables.stations[orbitable] = get_orbitable_data(orbitable)
		elif get_orbitable_type(orbitable) == "asteroid":
			# TODO this could be cleaner
			orbitable.connect("died", self, "_on_asteroid_died")
			orbitables.asteroids[orbitable] = get_orbitable_data(orbitable)
		else:
			orbitables.normal[orbitable] = get_orbitable_data(orbitable)

	last_timestamp = GameFlow.get_time_around_sun()
	update_orbitables(true)


func _on_asteroid_died(asteroid: Asteroid):
	orbitables.asteroids.erase(asteroid)


func _on_container_tethered(container: CargoContainer, target):
	print("Tethering container to player", container)
	if target == null:
		$DampedSpringJoint2D.node_a = ""
		$DampedSpringJoint2D.node_b = ""
		return

	container.sleeping = false
	# $Player/DampedSpringJoint2D.length = player.position.distance_to(container.position)
	$DampedSpringJoint2D.node_a = target.get_path()
	$DampedSpringJoint2D.node_b = container.get_path()




func update_transformation_to_sun(orbitable, orbitable_data):
	orbitable.position = (orbitable_data.original_position - sun.position).rotated(last_timestamp * 2 * PI * orbitable.orbit_speed) + sun.position
	orbitable.rotation =  last_timestamp * 2 * PI * orbitable.orbit_speed + orbitable_data.original_rotation


func update_orbitables(include_ships = false):
	return
	for station in orbitables.stations:
		update_transformation_to_sun(station, orbitables.stations[station])

	for normal in orbitables.normal:
		update_transformation_to_sun(normal, orbitables.normal[normal])

	if include_ships:
		for asteroid in orbitables.asteroids:
			var asteroid_data = orbitables.asteroids[asteroid]
			asteroid.update_position((asteroid_data.original_position - sun.position).rotated(last_timestamp * 2 * PI * asteroid.orbit_speed) + sun.position)

		for ship in orbitables.ships:
			update_transformation_to_sun(ship, orbitables.ships[ship])
			if GameFlow.is_enemy(ship):
				ship.origin = ship.position


func _physics_process(delta):
	var now = GameFlow.get_time_around_sun()
	if (abs(now - last_timestamp) > 0.000001):
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
