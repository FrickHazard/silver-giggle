extends Polygon2D

class_name SegmentLeg

@export var range_rad = PI / 4



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

	
func get_capacity(target: Vector2):
	var direction_to_target = (target - position).normalized()	
	var target_angle = direction_to_target.angle()
	var ideal_leg_push_angle = (- direction_to_target).angle()
	var ideal_leg_push_angle_local = ideal_leg_push_angle - global_rotation
	ideal_leg_push_angle_local = wrapf(ideal_leg_push_angle_local, -range_rad, range_rad)
	var actual_angle = ideal_leg_push_angle_local + global_rotation
	var vec2 = Vector2(cos(actual_angle), sin(actual_angle))
	return {
		"vec2": vec2,
		"max_force": 1
	}
	
	
	
	
