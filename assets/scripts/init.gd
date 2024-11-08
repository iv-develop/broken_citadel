extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	CAMERA.follow_node = get_parent().get_node("Player")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
