extends Area2D

@export var perfer_zoom = 3.
@onready var area = self.get_node("AREA")
var rect : Rect2;
func _ready() -> void:
	var pos = area.global_position
	var size = area.shape.size
	rect = Rect2(pos - size * 0.5, pos + size * 0.5)
func _on_body_entered(body):
	if !body.is_in_group("Player"): return
	CAMERA.override_zoom = perfer_zoom
	CAMERA.room_bound_rects.append(rect)
func _on_body_exited(body):
	if !body.is_in_group("Player"): return
	CAMERA.override_zoom = 0.
	CAMERA.room_bound_rects.erase(rect)
	
