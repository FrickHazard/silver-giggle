class_name BaseAgent

extends CharacterBody2D

@export_category("Movement Stats")
@export var move_speed: float = 50.0
@export var jump_force: float = 150.0
@export var gravity: float = 600.0

var jump_cooldown: float = 0.5
var direction: int
var can_jump: bool = true
var was_on_floor : bool = false

@export_category("Preferences")
@export var wake_time : SignalBus.DaylightState 
@export var sleep_time : SignalBus.DaylightState 

@export_category("Components")
@export var ground_check: RayCast2D
@export var wall_check: RayCast2D
@export var visual : AnimatedSprite2D
@export var sound_player : AudioStreamPlayer2D
@export var pathfinding : NavigationAgent2D

@export_category("Sounds")
@export var jump_sound : AudioStream
@export var land_sound : AudioStream

enum State { ACTIVE, RESTING }
var current_state: State = State.ACTIVE

func _ready():
	SignalBus.switch_day_state.connect(_on_day_state_changed)

func _on_day_state_changed(new_state):
	if(new_state == wake_time):
		current_state = State.ACTIVE
	elif(new_state == sleep_time):
		current_state = State.RESTING

func _process(_delta):
	_update_sprite()
	check_landing()
	pass
	
func _physics_process(delta):
	_apply_gravity(delta)
	_update_wall_check()
	move_and_slide()
	pass
	
func _update_wall_check():
	if(velocity.x < 0):
		wall_check.target_position.x = -12
	else:
		wall_check.target_position.x = 4
		
func check_landing() -> void:
	if is_on_floor() and not was_on_floor:
		sound_player.stream = land_sound
		sound_player.play()
	was_on_floor = is_on_floor()
	
func _update_sprite():
	if(velocity.x > 0):
		visual.flip_h = false
	elif(velocity.x < 0):
		visual.flip_h = true
		
	if current_state == State.RESTING:
		visual.play("sleep")
	else:
		if is_on_floor() and abs(velocity.x) > 0:
			visual.play("run")
		elif is_on_floor() and velocity.x == 0:
			visual.play("idle")
		elif not is_on_floor():
			visual.play("fall")
	pass

func _apply_gravity(delta):
	if not is_on_floor():
		velocity.y += gravity * delta
	move_and_slide()

func _jump():
	if !can_jump or !ground_check.is_colliding():
		return
	
	sound_player.stream = jump_sound
	sound_player.play()
	
	velocity.y = -jump_force
	
	can_jump = false
	await get_tree().create_timer(jump_cooldown).timeout
	can_jump = true

func _follow_path():
	if pathfinding.distance_to_target() < 30:
		velocity.x = 0
		return

	var next_position = pathfinding.get_next_path_position()
	
	var jump_mult : float = 1
	if is_on_floor():
		jump_mult = 1
	else:
		jump_mult = 1.2
	
	if(next_position.x < position.x):
		velocity.x = -1 * move_speed * jump_mult
	else:
		velocity.x = 1 * move_speed * jump_mult

	if next_position.y < position.x && abs(next_position.x-position.x) < 5:
		_jump()
