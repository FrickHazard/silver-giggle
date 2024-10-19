extends Control
@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _on_play_pressed() -> void:
	animation_player.play("click")
	get_tree().change_scene_to_file("res://Scenes/test_world.tscn")


func _on_options_pressed() -> void:
	animation_player.play("click")
	get_tree().change_scene_to_file("res://Scenes/options_menu.tscn")


func _on_quit_pressed() -> void:
	get_tree().quit()
