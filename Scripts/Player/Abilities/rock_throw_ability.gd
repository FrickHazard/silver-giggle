extends BaseAbility

@export var rock_scene : PackedScene
@export var throw_force : float

@export var throw_sound : AudioStream
var audio_player_throw : AudioStreamPlayer2D

func _ready():
	audio_player_throw = AudioStreamPlayer2D.new()
	audio_player_throw.volume_db = -20
	audio_player_throw.stream = throw_sound
	add_child(audio_player_throw)

func use(input_direction : Vector2):
	audio_player_throw.play()
	
	input_direction.y = -input_direction.y
	
	var rock_instance = rock_scene.instantiate() as RigidBody2D
	rock_instance.position = user.position + (input_direction*10)
	
	get_tree().root.add_child(rock_instance) 
	
	rock_instance.apply_central_impulse(input_direction*throw_force)
