extends Node2D

onready var ContainerScene = preload("res://src/game/Container.tscn")
onready var MaterialScene = preload("res://src/game/Material.tscn")

onready var container = $Container
onready var station = $Stations/Station
onready var projectiles = $Projectiles
onready var player = $Player
onready var speed_lines = $SpeedLines
onready var igps = $IGPS
onready var enemy = $Enemies/ArmadeAgile
onready var enemy_text = $Texts/EnemyText
onready var material_drop = $Material


onready var spring = $Player/DampedSpringJoint2D

const shells = {
	"default": preload("res://src/game/shells/DefaultShell.tscn"),
	"armada": preload("res://src/game/shells/ArmadaShell.tscn"),
	"rot": preload("res://src/game/shells/RotShell.tscn"),
	"solreign": preload("res://src/game/shells/SolreignShell.tscn"),
	"post": preload("res://src/game/shells/CarrotShell.tscn"),
}

var previous_velocity = Vector2(0, 0)

var station_map = {}


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

	GameFlow.update_player(player)

	material_drop.connect("picked_up", self, "_on_picked_up")

	enemy.connect("died", self, "_on_enemy_died")

	container.destination = station
	container.connect("tether", self, "_on_container_tethered")


func _on_enemy_died(_enemy):
	enemy_text.text = "Well done!"

func swap_player(shell = null, shell_name = null):
	var camera = player.get_node("PlayerCamera")

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
	add_child(player)
	if shell != null:
		shell.get_parent().update_type(old_type)
	State.player.shell = player.shell_name

	player.position = old_position
	player.rotation = old_rotation
	player.destinations = old_destinations
	player.velocity = old_velocity
	player.add_child(camera)
	player.add_child(spring)
	GameFlow.update_player(player)


func drop_material(enemy, material_type):
	var material_instance = MaterialScene.instance()
	material_instance.position = enemy.position
	material_instance.set_type(material_type)
	add_child(material_instance)
	material_instance.connect("picked_up", self, "_on_picked_up")


func _on_picked_up(material):
	if not GameFlow.is_in_battle():
		State.add_material(material.type, 1)
		yield(get_tree().create_timer(0.0), "timeout")
		remove_child(material)
		material.queue_free()
		Flow.save_game()


func _on_container_tethered(container: CargoContainer, target):
	if target == null:
		spring.node_a = ""
		spring.node_b = ""
		return

	GameFlow.destination = container.destination
	container.sleeping = false
	# spring.length = 1
	# spring.rest_length = 1
	# $Player/DampedSpringJoint2D.length = player.position.distance_to(container.position)
	spring.node_a = target.get_path()
	spring.node_b = container.get_path()


func _physics_process(delta):
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
