extends AnimatedSprite2D

const bug_speed = 20
const min_move_time: float = 8.0

var direction = 1
var stop_chance = 0.01  # Chance of stopping each frame
var fixed_stop_time: float = 3.0  # Fixed pause time in seconds
var stop_timer: float = 0.0
var move_timer: float = 0.0
var is_stopping = false

@onready var ray_cast_right: RayCast2D = $RayCastRight
@onready var ray_cast_left: RayCast2D = $RayCastLeft
@onready var small_bug: AnimatedSprite2D = $"."

func _process(delta):
	if is_stopping:
		stop_timer -= delta
		if stop_timer <= 0:
			is_stopping = false  # End the stop phase
			small_bug.play("move")  # Resume moving animation
			move_timer = 0
		return  # Skip the rest of the movement logic during stop

	move_timer += delta

	# Randomly trigger a stop
	if move_timer >= min_move_time and randf() < stop_chance:
		is_stopping = true
		stop_timer = fixed_stop_time
		print("Stopping for:", stop_timer)
		small_bug.play("eat")  # Play eating animation during stop
		return  # Exit to prevent movement this frame

	# Movement and direction flipping when hitting walls
	if ray_cast_right.is_colliding():
		direction = -1
		small_bug.flip_h = false
	elif ray_cast_left.is_colliding():
		direction = 1
		small_bug.flip_h = true

	# Move in the current direction only if not stopping
	position.x += direction * bug_speed * delta
