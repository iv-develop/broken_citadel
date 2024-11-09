extends Node

func _ready() -> void:
	pass
	
func _process(d: float) -> void:
	get_parent().get_node("Game/DBG/Label").text = str(Engine.get_frames_per_second())
