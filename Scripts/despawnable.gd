extends Node
class_name Despawnable

func _ready() -> void:
	await get_tree().create_timer(3.0).timeout
	queue_free()
	pass 
