extends Area2D

export var shell_name = "armada"
onready var collision_shape = $CollisionShape2D



const textures = {
	"armada": preload("res://assets/graphics/ships/player/armada.png"),
	"default": preload("res://assets/graphics/ships/player/standard.png"),
	"post": preload("res://assets/graphics/ships/player/carrot.png"),
	"rot": preload("res://assets/graphics/ships/player/rot.png"),
	"solreign": preload("res://assets/graphics/ships/player/solreign.png"),
}


func _ready():
	connect("body_entered", self, "_on_body_entered")
	connect("body_exited", self, "_on_body_exited")


func update_shell(new_shell):
	shell_name = new_shell
	$Sprite.texture = textures[new_shell]


func _on_body_entered(body):
	if GameFlow.is_player(body):
		GameFlow.overlays.popup.show_popup_custom("Swap ships by pressing E", Vector2(0, 40), "info", 3)
		body.swappable_shell = self



func _on_body_exited(body):
	if GameFlow.is_player(body):
		body.swappable_shell = null

