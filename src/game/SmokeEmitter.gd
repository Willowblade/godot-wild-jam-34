extends Emitter
class_name SmokeEmitter

onready var emitter: CPUParticles2D = $Medium

var max_particles = 128
var min_particles = 4
var initial_velocity = 50
var min_initial_velocity = 15
var spread = 15
var min_spread = 5

func _ready():
	pass



func set_intensity(intensity: float):
	if intensity == 0.0:
		emitter.emitting = false
	else:
		emitter.emitting = true

	emitter.spread = int(min_spread + (spread - min_spread) * intensity)
	emitter.amount = int(min_particles + (max_particles - min_particles) * intensity)
	emitter.spread = min_initial_velocity + (initial_velocity - min_initial_velocity) * intensity

