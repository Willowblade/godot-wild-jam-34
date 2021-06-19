extends Node2D
class_name Shield

onready var sprite = $Sprite

var flash_time = 0.3
var flash_timer = 1.0
var intensity = 0.7
var min_intensity = 0.2

var general_dimness = 0.7


func _ready():
	set_intensity(1.0)


func set_intensity(_intensity):
	intensity = max(min_intensity, _intensity * general_dimness)
	if flash_timer > flash_time:
		sprite.modulate.a = intensity

func get_hit():
	flash_timer = 0
	set_process(true)

func enable():
	print("Enabling shield")
	sprite.visible = true

func break_shield():
	$Emitter.emitting = true
	$Emitter.visible = true
	sprite.visible = false


func _process(delta):
	flash_timer += delta
	if flash_timer > flash_time:
		set_process(false)

	sprite.modulate.a = 0.8 - (0.8 - intensity) * min(flash_timer / flash_time, 1.0)
