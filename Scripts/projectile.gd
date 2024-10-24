extends RigidBody2D

@export var damage: int = 1
@export var is_dangerous : bool = true

func _ready() -> void:
	connect("body_entered", _on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if !is_dangerous: 
		return

	for child in body.get_children():
		if child.has_method("_take_damage"):
			child._take_damage(damage)
			is_dangerous = false
			await get_tree().create_timer(1).timeout
			queue_free()
	pass
