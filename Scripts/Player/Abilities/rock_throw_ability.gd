extends BaseAbility

@export var rock_scene : PackedScene
@export var throw_force : float

func use(input_direction : Vector2):
	print("use rock")

	var rock_instance = rock_scene.instantiate() as RigidBody2D
	rock_instance.position = user.position + input_direction
	print(position)
	get_tree().root.add_child(rock_instance)  # Add rock to the root node, not the player

	rock_instance.apply_impulse(input_direction*throw_force)
