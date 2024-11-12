extends Area2D

var activated = false

var tracking_player_body = null

func _physics_process(delta: float) -> void:
	if !self.activated: return
	if tracking_player_body:
		var r = rotation
		if r < 0: r += PI * 2.0
		if r < PI / 4.0:
			tracking_player_body.velocity.y = -300
		elif r < 3 * PI / 4.0:
			tracking_player_body.velocity.x = 300
		elif r < PI + PI / 4.0:
			tracking_player_body.velocity.x = 300
		elif r < PI + 3 * PI / 4.0:
			tracking_player_body.velocity.y = -300

func _ready() -> void:
	if default_activated: self.activate()
	

func _on_flow_body_entered(body: Node2D) -> void:
	if !body.is_in_group("Player"): return
	tracking_player_body = body

@export var default_activated = false

func _on_flow_body_exited(body: Node2D) -> void:
	if !body.is_in_group("Player"): return
	tracking_player_body = null

func reset():
	$AnimationPlayer.play("RESET")
	$CPUParticles2D.emitting = false
	self.activated = false
	if default_activated: self.activate()

func activate(q=false):
	self.activated = true
	if !q:
		$String.pitch_scale = randf_range(0.7, 1.4)
		$String.play(0)
	$CPUParticles2D.emitting = true
	$AnimationPlayer.play("pop")
