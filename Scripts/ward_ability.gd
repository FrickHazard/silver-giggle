extends BaseAbility

@export var light : Node2D

func use():
	print("use ward")
	light.visible = !light.visible
	pass
