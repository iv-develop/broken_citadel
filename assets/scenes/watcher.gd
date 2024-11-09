extends Node2D

var dead = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass




func _physics_process(delta: float) -> void:
	return
	var players = get_tree().get_nodes_in_group("Player")
	for player in players:
		var space_state = get_world_2d().direct_space_state
		var query = PhysicsRayQueryParameters2D.create(global_position, player.global_position, 1)
		var result = space_state.intersect_ray(query)
		if result and result["collider"] == player:
			var dir = (global_position - player.global_position).normalized();
			if dir.x > 0:
				self.rotation = atan2(dir.y, dir.x)
				$Sprite.flip_h = false
			else:
				self.rotation = atan2(-dir.y, -dir.x)
				$Sprite.flip_h = true
			$AnimationPlayer.play("Prepare")
			
