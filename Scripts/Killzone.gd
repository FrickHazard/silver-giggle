extends Area2D




func _on_body_entered(body: Node2D) -> void:
	print("Entered body name: ", body.name)  # Debugging to check the name
	if body.name == "Player":  # Check if the body is an enemy
		body.call_deferred("queue_free")
		get_tree().reload_current_scene()
		print("you stink")
