extends Control



func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/menu.tscn")



func _on_volume_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/audio_Slider_Settings.tscn")
