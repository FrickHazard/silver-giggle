extends CanvasLayer

@export var target : Node2D

func _process(delta):
	transform.x = target.position
	pass
