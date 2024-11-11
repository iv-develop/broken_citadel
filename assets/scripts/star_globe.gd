extends StaticBody2D


func _ready() -> void:
	pass # Replace with function body.


func _process(delta: float) -> void:
	pass


func take_damage(_g_pos, _vel, _d):
	$AnimationPlayer.play("TakeDamage")
