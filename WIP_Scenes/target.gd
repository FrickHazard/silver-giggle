extends Node2D

@export var speed = 50

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var vec = Vector2(0, 0)
	if Input.is_action_pressed("ui_right"):
		vec.x += 1
	if Input.is_action_pressed("ui_left"):
		vec.x -= 1
	if Input.is_action_pressed("ui_up"):
		vec.y -= 1
	if Input.is_action_pressed("ui_down"):
		vec.y += 1
	position += vec.normalized() * speed * delta
		# Move right.
