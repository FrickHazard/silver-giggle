extends Camera2D

var room_size = Vector2(200, 200)
var current_room = Vector2(100,100)

@export var player: CharacterBody2D

func _ready():
	_update_camera_position()

func _process(_delta: float) -> void:
	var player_room = _get_room_from_position(player.global_position)
	if player_room != current_room:
		current_room = player_room
		_update_camera_position()

func _update_camera_position() -> void:
	var new_camera_position = current_room * room_size + room_size / 2
	global_position = new_camera_position

func _get_room_from_position(room_position: Vector2) -> Vector2:
	return Vector2(floor(room_position.x / room_size.x), floor(room_position.y / room_size.y))
