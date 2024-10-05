extends BaseAbility

@export var light : Node2D

func use(_input_direction : Vector2):
	print("use ward")
	light.visible = !light.visible
	pass

func equip():
	light.visible = true
	pass
	
func unequip():
	light.visible = false
	pass
