extends Sprite2D

# Durability properties for the fragile surface
@export var max_durability = 100
var current_durability = max_durability
@export var break_threshold = 0




func damage_surface(damage_amount):
	current_durability -= damage_amount
	if current_durability <= break_threshold:
		break_surface()



func _on_Area2D_body_entered(body):
	if is_instance_valid(body) and body is Node:
		if body.has_method("get") and body.get("can_break_surface", false):
			damage_surface(20)



func _on_area_2d_body_entered(body: Node2D) -> void:
	if is_instance_valid(body) and body is Node:
		if body.get("can_break_surface"):
			damage_surface(20)

func break_surface():
	queue_free()  # Remove from scene if necessary
