extends Node
class_name Despawnable

@export var lifespan : float

func _ready() -> void:
	await get_tree().create_timer(lifespan).timeout
	queue_free()
	pass 
