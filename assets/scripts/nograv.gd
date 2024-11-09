extends Area2D


func _ready() -> void:
	pass # Replace with function body.


func _process(delta: float) -> void:
	pass


func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("Player"): return
	#body.in_space = true


func _on_body_exited(body: Node2D) -> void:
	if not body.is_in_group("Player"): return
	#body.in_space = false
