@tool
extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$StaticBody2D/CollisionShape2D.shape.points = $Polygon2D.polygon;


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
