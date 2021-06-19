extends Node2D


func _ready():
	GameFlow.register_hit_emitter($HitEmitter)
	GameFlow.register_projectiles_spawner($Projectiles)
