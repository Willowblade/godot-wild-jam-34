extends Emitter
class_name SmokeEmitter

onready var segment = 1.0 / children.size()

var max_amount = 32
var min_amount = 16
var max_initial_velocity = 40
var min_initial_velocity = 15
var max_spread = 15
var min_spread = 5
var max_scale_amount = 1.0
var min_scale_amount = 0.4


var phases = 3

var spread = false setget set_spread
var initial_velocity = false setget set_initial_velocity
var amount = false setget set_amount
var scale_amount = false setget set_scale_amount


func set_spread(new_spread):
	for child in children:
		child.spread = new_spread


func set_initial_velocity(new_initial_velocity):
	for child in children:
		child.initial_velocity = new_initial_velocity


func set_amount(new_amount):
	for child in children:
		child.amount = new_amount


func set_scale_amount(new_scale_amount):
	for child in children:
		child.scale_amount = new_scale_amount


func _ready():
	pass


func set_emitter_properties(emitter, modifier):
	if modifier < 0.01:
		emitter.emitting = false
	else:
		emitter.emitting = true
	emitter.spread = int(min_spread + (max_spread - min_spread) * modifier)
	emitter.amount = int(min_amount + (max_amount - min_amount) * modifier)
	emitter.initial_velocity = int(min_initial_velocity + (max_initial_velocity - min_initial_velocity) * modifier)
	emitter.scale_amount = min_scale_amount + (max_scale_amount - min_scale_amount) * modifier


func set_intensity(intensity: float):
	var i = 0
	for child in children:
		var segment_size = i * segment / phases
		var modifier = 0.0
		if intensity > float(phases - 1) / phases:
			modifier = 0.6666 + max(0.0, min(1.0, (intensity - segment_size - (phases - 1) / phases) / segment)) / 3
		elif intensity > float(phases - 2) / phases:
			modifier = 0.3333 + max(0.0, min(1.0, (intensity - segment_size - (phases - 2) / phases) / segment)) / 3
		elif intensity > float(phases - 3) / phases:
			modifier = max(0.0, min(1.0, (intensity - segment_size - (phases - 3) / phases) / segment)) / 3
		set_emitter_properties(child, modifier)
		i += 1
