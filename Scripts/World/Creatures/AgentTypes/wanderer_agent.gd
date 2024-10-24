extends BaseAgent

var jump_attempts: int
var jump_timer: Timer
var direction_timer: Timer

func _ready() -> void:
	super._ready()
	if randi_range(1, 3) == 1:
		direction = 1
	else:
		direction = -1
	
	jump_timer = Timer.new()
	jump_timer.wait_time = randi_range(2, 5)
	jump_timer.one_shot = false
	add_child(jump_timer)
	jump_timer.connect("timeout", _on_jump_timer_timeout)
	jump_timer.start()
	
	direction_timer = Timer.new()
	direction_timer.wait_time = randi_range(3, 7)
	direction_timer.one_shot = false
	add_child(direction_timer)
	direction_timer.connect("timeout",_on_direction_timer_timeout)
	direction_timer.start()

func _process(delta: float) -> void:
	super._process(delta)
	match current_state:
		BaseAgent.State.ACTIVE:
			_wander()
		BaseAgent.State.RESTING:
			velocity.x = 0

func _wander():
	velocity.x = direction * move_speed
	if wall_check.is_colliding() && is_on_floor():
		if jump_attempts > 5:
			direction = -direction
			jump_attempts = 0 
		else: 
			_jump()
			jump_attempts += 1

func _on_jump_timer_timeout() -> void:
	if(current_state == State.RESTING):
		return
	_jump()
	jump_timer.wait_time = randi_range(2, 4)
	jump_timer.start()

func _on_direction_timer_timeout() -> void:
	if(current_state == State.RESTING):
		return
	direction = -direction
	direction_timer.wait_time = randi_range(10, 15)
	direction_timer.start()
