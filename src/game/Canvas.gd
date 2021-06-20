extends Node2D

onready var ContainerScene = preload("res://src/game/Container.tscn")
onready var MaterialScene = preload("res://src/game/Material.tscn")

onready var projectiles = $Projectiles
onready var player = $Player
onready var speed_lines = $SpeedLines
onready var sun = $Sun
onready var igps = $IGPS

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
	"carrot": preload("res://src/game/shells/CarrotShell.tscn"),
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
	GameFlow.register_canvas(self)
	GameFlow.register_hit_emitter($HitEmitter)
	GameFlow.register_projectiles_spawner($Projectiles)
	AudioEngine.play_background_music("explore")
	GameFlow.overlays.transition.set_color(Color(0, 0, 0, 1))
	GameFlow.overlays.transition.transition_to_clear()
	GameFlow.destination = null
	GameFlow.igps = igps
	GameFlow.sun = sun

	GameFlow.update_player(player)
	if State.player.shell != player.shell_name:
		swap_player(null, State.player.shell)

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
	player.position = igps.position + 128 * Vector2.DOWN


func swap_player(shell = null, shell_name = null):
	var camera = player.get_node("PlayerCamera")
	player.remove_child(camera)
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
	add_child(player)
	if shell != null:
		shell.get_parent().update_type(old_type)
	State.player.shell = player.shell_name
	Flow.save_game()

	player.position = old_position
	player.rotation = old_rotation
	player.destinations = old_destinations
	player.velocity = old_velocity
	player.add_child(camera)
	GameFlow.update_player(player)


func drop_material(enemy, material_type):
	var container_instance = MaterialScene.instance()
	container_instance.position = enemy.position
	container_instance.set_type(material_type)
	add_child(container_instance)
	container_instance.connect("picked_up", self, "_on_picked_up")


func _on_picked_up(material):
	if not GameFlow.is_in_battle():
		State.add_material(material.type, 1)
		yield(get_tree().create_timer(0.0), "timeout")
		remove_child(material)
		material.queue_free()
		Flow.save_game()


func spawn_container_with_destination(destination):
	var container_instance = ContainerScene.instance()
	container_instance.position = igps.cargo_spawn_point.global_position
	container_instance.destination = destination
	add_child(container_instance)
	container_instance.connect("tether", self, "_on_container_tethered")

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
