extends Area2D

var activated = false

var tracking_player_body = null

func _physics_process(delta: float) -> void:
	if !self.activated: return
	if tracking_player_body:
		tracking_player_body.velocity.y = -300;


func _on_flow_body_entered(body: Node2D) -> void:
	if !body.is_in_group("Player"): return
	tracking_player_body = body


func _on_flow_body_exited(body: Node2D) -> void:
	if !body.is_in_group("Player"): return
	tracking_player_body = null


func _on_area_entered(area: Area2D) -> void:
	if !area.is_in_group("Rapier"): return
	self.activated = true
	$CPUParticles2D.emitting = true
	$AnimationPlayer.play("pop")
