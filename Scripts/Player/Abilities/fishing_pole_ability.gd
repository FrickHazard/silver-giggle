extends BaseAbility

@export var bobber : RigidBody2D
@export var line_render : Line2D

@export var cast_strength : int

func use(input_direction : Vector2):
	print("use fishing pole")
	if bobber.visible != true:
		bobber.visible = true
		bobber.get_parent().remove_child(bobber)
		bobber.reparent(get_tree().root)
		
		line_render.add_point(Vector2.ZERO)
		line_render.add_point(Vector2.ZERO)
		
		#bobber.add_constant_force(input_direction*cast_strength)
	else:
		bobber.visible = false
		add_child(bobber)
		
		bobber.position = position + Vector2.UP
		bobber.set_axis_velocity(Vector2.ZERO)
	pass
	
func equip():
	pass
	
func unequip():
	bobber.visible = false
	line_render.clear_points()
	pass

func _process(delta):
	if bobber.visible:
		line_render.set_point_position(0, position)
		line_render.set_point_position(1, bobber.position)
