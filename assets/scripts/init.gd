extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	CAMERA.follow_node = get_parent().get_node("Player")
