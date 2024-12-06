extends Node2D

var velocity = 0

var force = 0

var height = 0

var target_height = 0

var index = 0

var motion_factor = 0.02

signal splash


func water_update(spring_constant, dampening):
	
	height = position.y
	
	var x = height - target_height
	
	var loss = -dampening * velocity
	
	force = - spring_constant * x + loss
	
	velocity += force
	
	position.y += velocity
	
	pass

@onready var collision = $Area2D/CollisionShape2D

func initialize(x_position, id):
	height = position.y
	target_height = position.y
	velocity = 0
	position.x = x_position
	index = id

func set_collision_width(value):
	if collision.shape is RectangleShape2D:
		var rect_shape = collision.shape as RectangleShape2D
		var extents = rect_shape.extents
		rect_shape.extents = Vector2(value / 2, extents.y)

	
	pass
	
	
	

func _on_area_2d_body_entered(body: Node2D) -> void: 	
	
	if body is BasicPlayerMovement:
		var speed = body.motion.y * motion_factor
		emit_signal("splash", index, speed)
	
	
	
	
	pass # Replace with function body.
