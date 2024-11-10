extends Area2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		if body.hp > 0:
			$AnimationPlayer.play("Roll")
			GAME.save_checkpoint()
			$Checkpoint.pitch_scale = randf_range(0.6, 0.8)
			$Checkpoint.play(0)
