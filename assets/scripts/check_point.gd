extends Area2D


func _ready() -> void:
	pass


func _process(delta: float) -> void:
	pass


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		if body.hp > 0:
			$AnimationPlayer.play("Roll")
			#if (GAME.last_checkpoint_pos - self.global_position).length_squared() > 200.:
			GAME.save_checkpoint()
			$Checkpoint.pitch_scale = randf_range(0.6, 0.8)
			$Checkpoint.play(0)
	
