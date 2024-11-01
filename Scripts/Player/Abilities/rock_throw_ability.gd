extends BaseAbility

@export var rock_scene : PackedScene
@export var throw_force : float

@export var throw_sound : AudioStream
var audio_player_throw : AudioStreamPlayer2D

func _ready():
	audio_player_throw = AudioStreamPlayer2D.new()
	audio_player_throw.volume_db = -10
	audio_player_throw.stream = throw_sound
	add_child(audio_player_throw)

func use(input_direction: Vector2):
	audio_player_throw.play()
	
	input_direction.y = -input_direction.y
	
	# Calculate the intended spawn position for the rock
	var spawn_position = user.position + (input_direction * 10)
	
	var query = PhysicsPointQueryParameters2D.new()
	query.position = spawn_position
	query.exclude = []  # You can specify which bodies to exclude if needed
	query.collision_mask = 0b1111111111111111  # Check against all layers, adjust as needed
	
	# Perform the point query
	var space_state = get_world_2d().direct_space_state
	var result = space_state.intersect_point(query)
	
	# If there is no collision at the spawn position, spawn the rock
	if result.size() == 0:
		var rock_instance = rock_scene.instantiate() as RigidBody2D
		rock_instance.position = spawn_position
		get_tree().root.add_child(rock_instance)
		rock_instance.apply_central_impulse(input_direction * throw_force)
