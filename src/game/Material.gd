extends Area2D

export var type = ""

signal picked_up

const textures = {
	"armada": preload("res://assets/graphics/ships/armada/collectible.png"),
	"rot": preload("res://assets/graphics/ships/rot/collectible.png"),
	"solreign": preload("res://assets/graphics/ships/solreign/collectible.png"),
}

const modulates = {
	"armada": Color(1, 1, 1, 1),
	"rot": Color(0, 1, 0, 1),
	"solreign": Color(1, 1, 0, 1),
}

func _ready():
	connect("body_entered", self, "_on_body_entered")
	set_type(type)

func _on_body_entered(body):
	if GameFlow.is_player(body):
		emit_signal("picked_up", self)

func set_type(_type):
	$Sprite.texture = textures[_type]
	$CPUParticles2D2.modulate = modulates[_type]
	type = _type
