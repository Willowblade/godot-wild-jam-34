extends Control

func _ready():
	GameFlow.register_markers($UICanvas/Markers)
	GameFlow.register_map($UICanvas/Map)
	GameFlow.map.initialize_objects()
	GameFlow.map.set_player(GameFlow.player)
