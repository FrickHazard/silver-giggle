extends CharacterBody2D

@export var move_speed := 50.0
@export var acceleration := 1000.0
@export var deceleration := 1500.0
@export var max_speed := 100.0

@export var jump_force := 250.0
@export var jump_cut_off := 100.0
@export var gravity := 1200.0
@export var coyote_time := 0.2
@export var jump_buffer_time := 0.15
@export var max_fall_speed := 500.0

var is_jumping := false
var jump_buffer := 0.0
var coyote_timer := 0.0

func _ready():
	pass

func _physics_process(delta: float) -> void:
	handle_input(delta)
	apply_gravity(delta)
	apply_jump_logic(delta)
	apply_coyote_time(delta)
	clamp_falling_speed()
	move_and_slide()

func handle_input(delta: float) -> void:
	var input_dir := Vector2.ZERO
	input_dir.x = Input.get_axis("move_left", "move_right")
	
	if input_dir.x != 0:
		velocity.x = move_toward(velocity.x, input_dir.x * max_speed, acceleration * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, deceleration * delta)

	if Input.is_action_just_pressed("jump"):
		jump_buffer = jump_buffer_time

	if Input.is_action_just_released("jump") and velocity.y < -jump_cut_off:
		velocity.y = jump_cut_off

func apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		velocity.y = 0

func apply_jump_logic(delta: float) -> void:
	jump_buffer = max(0, jump_buffer - delta)

	if jump_buffer > 0 and (is_on_floor() or coyote_timer > 0):
		jump()
		jump_buffer = 0

	if is_on_floor():
		coyote_timer = coyote_time
	else:
		coyote_timer = max(0, coyote_timer - delta)

func jump() -> void:
	velocity.y = -jump_force

func apply_coyote_time(delta: float) -> void:
	if is_on_floor():
		coyote_timer = coyote_time
	else:
		coyote_timer = max(0, coyote_timer - delta)

func clamp_falling_speed() -> void:
	if velocity.y > max_fall_speed:
		velocity.y = max_fall_speed