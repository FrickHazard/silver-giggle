@tool
extends EditorPlugin

var generate_button : Button

func _enter_tree() -> void:
	generate_button = Button.new()
	generate_button.text = "Generate Foliage"
	
	add_control_to_dock(EditorPlugin.DOCK_SLOT_LEFT_BL, generate_button)
	pass


func _exit_tree() -> void:
	remove_control_from_docks(generate_button)
	generate_button.queue_free()
	pass
