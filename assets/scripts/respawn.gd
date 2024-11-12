extends Node2D

var clone : Node = null
var instance : Node = null
@export var as_spawner = false
func _ready() -> void:
	for n in get_children():
		instance = n
		clone = n.duplicate()
		return

@export var respawn_time = 2.0
var time_since_despawn = 0.0
func _process(delta: float) -> void:
	if as_spawner and clone:
			time_since_despawn += delta
			if time_since_despawn >= respawn_time:
				var n = clone.duplicate()
				add_child(n)
				time_since_despawn = 0.0
	else:
		if clone and not is_instance_valid(instance):
			time_since_despawn += delta
			if time_since_despawn >= respawn_time:
				reset()

func reset():
	if is_instance_valid(instance): instance.queue_free()
	if clone:
		var n = clone.duplicate()
		time_since_despawn = 0.0
		instance = n
		add_child(n)
