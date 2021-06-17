extends Node2D

onready var HitEffectScene = preload("res://src/game/HitEmitter.tscn")


func _ready():
	pass


func spawn_hit(hit_position: Vector2, type = "default"):
	var hit_emitter_instance = HitEffectScene.instance()
	add_child(hit_emitter_instance)
	hit_emitter_instance.position = hit_position
	hit_emitter_instance.emitting = true
	yield(get_tree().create_timer(hit_emitter_instance.lifetime), "timeout")
	remove_child(hit_emitter_instance)
	hit_emitter_instance.queue_free()
