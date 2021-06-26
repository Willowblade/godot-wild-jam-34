extends Node2D

onready var ContainerScene = preload("res://src/game/Container.tscn")
onready var MaterialScene = preload("res://src/game/Material.tscn")

onready var projectiles = $Projectiles
onready var player = $Player
onready var speed_lines = $SpeedLines
onready var sun = $Sun
onready var igps = $IGPS

onready var spring = $Player/DampedSpringJoint2D
var carried_containers = []

onready var orbitable_nodes = get_tree().get_nodes_in_group("orbitable")
onready var orbitables = {
	"ships": {},
	"stations": {},
	"asteroids": {},
	"normal": {},
}

const shells = {
	"default": preload("res://src/game/shells/DefaultShell.tscn"),
	"armada": preload("res://src/game/shells/ArmadaShell.tscn"),
	"rot": preload("res://src/game/shells/RotShell.tscn"),
	"solreign": preload("res://src/game/shells/SolreignShell.tscn"),
	"post": preload("res://src/game/shells/CarrotShell.tscn"),
}



var predefined_packages = {
	"1": "Station 1 hasn't read their mail in years. Press TAB to open up your map!",
	"2": "Station 2 has been in a rut lately, bring them this CD of Inside",
	"3": "All eyes on me, all eyes on - Oh. Hi. Deliver this underwear to Station 3",
	"4": "How's fighting all those pirates going? Yeah, they tricked me into coming here too.",
	"5": "If you can deliver these ship prototypes to Station 5, we'll give you the first one!",
}

var start_objective = "We need you to pick up a package at the IGPS"

var comeback_message = "Great job! Come back to the IGPS for your next assignment"

var random_messages = [
	"Deliver a live monkey to Station ",
	"Deliver this whole crate filled with pride flags to Station ",
	"A fuckton of carrots needs delivering to Station ",
	"We need you to deliver this batch of weapons to Station ",
	"Spare parts for vibrators - don't ask - are very hastily needed at Station ",
]
# TODO on start set tethered to ship?


func make_delivery_message(station):
	var delivered_packets = State.player.delivered_packets
	if station.station_name in delivered_packets:
		return random_messages[randi() % random_messages.size()] + station.station_name
	else:
		return predefined_packages[station.station_name]


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

var station_map = {}

func get_orbitable_data(orbitable):
	return {
		"distance": sun.position.distance_to(orbitable.position),
		"original_position": orbitable.position,
		"original_rotation": orbitable.rotation
	}


func get_container_destination():
	var delivered_packets = State.player.delivered_packets
	for i in range(5):
		if str((i + 1)) in delivered_packets:
			continue
		else:
			return str(i + 1)
	return str(1 + (randi() % 5))


func _ready():
	for station in get_tree().get_nodes_in_group("station"):
		station_map[station.station_name] = station


	GameFlow.register_canvas(self)
	GameFlow.register_hit_emitter($HitEmitter)
	GameFlow.register_projectiles_spawner($Projectiles)
	AudioEngine.play_background_music("explore")
	GameFlow.overlays.transition.set_color(Color(0, 0, 0, 1))
	GameFlow.overlays.transition.transition_to_clear(1.5)
	GameFlow.destination = null
	GameFlow.igps = igps
	GameFlow.sun = sun
	GameFlow.objective = start_objective
	GameFlow.overlays.popup.show_popup_custom(GameFlow.objective, Vector2(0, 40), "info", 3)

	GameFlow.update_player(player)
	if State.player.shell != player.shell_name:
		swap_player(null, State.player.shell)

	for enemy in get_tree().get_nodes_in_group("enemy"):
		enemy.connect("died", self, "_on_enemy_died")

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

	var spawn_container_destination = station_map[get_container_destination()]
	spawn_container_with_destination(spawn_container_destination)

	last_timestamp = GameFlow.get_time_around_sun()
	update_orbitables(true)
	player.position = igps.position + 256 * Vector2.DOWN


func _on_enemy_died(enemy: Enemy):
	GameFlow.remove_follower(enemy)

func swap_player(shell = null, shell_name = null):
	var camera = player.get_node("PlayerCamera")

	spring.node_a = ""
	spring.node_b = ""

	player.remove_child(camera)
	player.remove_child(spring)
	var old_type = player.shell_name
	var old_rotation = player.rotation
	var old_position = player.position
	var old_velocity = player.velocity
	var old_destinations = player.destinations
	# camera.smoothing_enabled = false
	# camera.position = player.position
	remove_child(player)
	player.queue_free()
	# call_deferred("queue_free", player)
	if shell != null:
		player = shells[shell.shell_name].instance()
	else:
		player = shells[shell_name].instance()

	player.position = old_position
	player.rotation = old_rotation
	player.destinations = old_destinations
	player.velocity = old_velocity
	add_child(player)

	if shell != null:
		shell.get_parent().update_type(old_type)
	State.player.shell = player.shell_name
	Flow.save_game()


	player.add_child(camera)
	player.add_child(spring)

	for container in carried_containers:
		container.player = player
		call_deferred("connect_spring", player, container)
#		spring.node_a = player.get_path()
#		spring.node_b = container.get_path()

	GameFlow.update_player(player)

func connect_spring(player, container):
	print("Connecting container to player...")
	container.connect_to_player(player)

func drop_material(enemy, material_type):
	var material_instance = MaterialScene.instance()
	material_instance.position = enemy.position
	material_instance.set_type(material_type)
	add_child(material_instance)
	material_instance.connect("picked_up", self, "_on_picked_up")


func _on_picked_up(material):
	# if not GameFlow.is_in_battle():
	State.add_material(material.type, 1)
	yield(get_tree().create_timer(0.0), "timeout")
	remove_child(material)
	material.queue_free()
	Flow.save_game()


func spawn_container_with_destination(destination):
	var container_instance = ContainerScene.instance()
	add_child(container_instance)
	container_instance.position = igps.cargo_spawn_point.global_position
	container_instance.destination = destination
	container_instance.connect("tether", self, "_on_container_tethered")

func _on_asteroid_died(asteroid: Asteroid):
	orbitables.asteroids.erase(asteroid)


func _on_container_tethered(container: CargoContainer, target):
	if GameFlow.is_player(target):
		if not container in carried_containers:
			carried_containers.append(container)
	else:
		if container in carried_containers:
			carried_containers.erase(container)

	if target == null:
		spring.node_a = ""
		spring.node_b = ""
		return


	GameFlow.destination = container.destination
	GameFlow.objective = make_delivery_message(container.destination)
	GameFlow.overlays.popup.show_popup_custom(GameFlow.objective, Vector2(0, 40), "info", 3)
	container.sleeping = false
	# spring.length = 1
	# spring.rest_length = 1
	# $Player/DampedSpringJoint2D.length = player.position.distance_to(container.position)
	spring.node_a = target.get_path()
	spring.node_b = container.get_path()




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
