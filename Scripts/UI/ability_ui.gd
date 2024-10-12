extends Node


@export var ability_display : TextureRect


func update_ability_display(new_texture : Texture2D):
	ability_display.texture = new_texture
