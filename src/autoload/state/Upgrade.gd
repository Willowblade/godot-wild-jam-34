extends Reference
class_name UpgradeState

var armada := 0
var solreign := 0
var rot := 0
var post := 0

var context : Dictionary setget set_context, get_context
func set_context(value : Dictionary) -> void:
	armada = value.get('armada', 0)
	solreign = value.get('solreign', 0)
	rot = value.get('rot', 0)
	post = value.get('post', 0)

	print("Loaded upgrade context ", value)


func get_context() -> Dictionary:
	var _context := {}

	_context.armada = armada
	_context.solreign = solreign
	_context.rot = rot
	_context.post = post

	return _context
