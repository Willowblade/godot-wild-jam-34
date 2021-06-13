extends Node2D

onready var projectiles = $Projectiles
onready var player = $Player



func _ready():
	player.connect("shoot", projectiles, "_on_projectile_fired")
