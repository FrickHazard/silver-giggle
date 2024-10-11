extends BaseAbility

@export var rock_scene : PackedScene
@export var throw_force : float

func use(input_direction : Vector2):
	print("use rock")

	var rock_instance = rock_scene.instantiate() as RigidBody2D
	rock_instance.position = user.position + input_direction
	get_tree().root.add_child(rock_instance) 

	rock_instance.linear_velocity = input_direction*throw_force
