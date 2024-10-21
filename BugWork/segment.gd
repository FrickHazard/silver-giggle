extends RigidBody2D

@export var target: Node2D;
@export var max_speed = 200
@export var max_angular_velocity = 200

@export var left_legs : Array[SegmentLeg] = [];
@export var right_legs : Array[SegmentLeg] = [];

@export var leg_grab_abandon_angle = deg_to_rad(140)
	
var draw_debug_info = false
	
func draw_vector_head(start: Vector2, end: Vector2, arrow_size=10, arrow_width =5):
	var direction = (end - start).normalized()
	var perpendicular = Vector2(-direction.y, direction.x)

	# Calculate the two points for the arrowhead lines
	var arrow_point1 = end - (direction * arrow_size) + (perpendicular * arrow_width)
	var arrow_point2 = end - (direction * arrow_size) - (perpendicular * arrow_width)

	# Draw the arrowhead
	draw_line(end, arrow_point1, Color(1, 0, 0), 2)  # Left side of arrow
	draw_line(end, arrow_point2, Color(1, 0, 0), 2)  # Right side of arrow

func draw_vector(start: Vector2, end: Vector2, color: Color = Color(1, 0, 0), width: float = 6, arrow_size: float =10, arrow_width: float =5):
	# Draw the vector (main line)
	draw_line(start, end, color, width)  # Red vector line
		
	# Draw the vector head (arrow)
	draw_vector_head(start, end, arrow_size, arrow_width)


var is_set_1_grabbing = true
var set_1_legs = []
var set_2_legs = []
var legs = []
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Concatenate legs together	
	legs = left_legs + right_legs
	# Zipper based on how some insects us every other leg on each side to push themselves forward
	var is_set_1_turn = true
	var set_1_is_left = true
	var set_2_is_left = false
	var left_index = 0
	var right_index = 0
	while left_index < len(left_legs) or right_index < len(right_legs):
		if is_set_1_turn:
			if (set_1_is_left and left_index < len(left_legs)) or right_index == len(right_legs):
				set_1_legs.append(left_index)
				left_index += 1
				set_1_is_left = !set_1_is_left
			else: 
				set_1_legs.append(right_index + len(left_legs))
				right_index += 1
				set_1_is_left = !set_1_is_left
		else:
			if (set_2_is_left and left_index < len(left_legs)) or right_index == len(right_legs):
				set_2_legs.append(left_index)
				left_index += 1
				set_2_is_left = !set_2_is_left
			else: 
				set_2_legs.append(right_index + len(left_legs))
				right_index += 1
				set_2_is_left = !set_2_is_left
		is_set_1_turn = !is_set_1_turn
		 
	# Intialize who is grabbing first	
	for l_idx in set_1_legs:
		legs[l_idx].should_grab = is_set_1_grabbing
	
	for l_idx in set_2_legs:
		legs[l_idx].should_grab = !is_set_1_grabbing


var vecs_to_draw = []
func _draw():
	if not draw_debug_info:
		vecs_to_draw = []
		return
	for vec in vecs_to_draw:
		draw_vector(to_local(vec[0]), to_local(vec[1]), vec[2], vec[3])
	vecs_to_draw = []
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	queue_redraw()	
	
	# Damping
	#linear_velocity = Vector2(20, 20).min(linear_velocity.lerp(Vector2.ZERO, 0.9 * delta))
	##angular_velocity = angular_velocity * 0.7 * delta
	#angular_velocity = 0
	#linear_velocity =  Vector2(0, 0)
	#.min(linear_velocity.lerp(Vector2.ZERO, 0.9 * delta))
	
	# Alternte between legs	
	var active_set = set_1_legs if is_set_1_grabbing else set_2_legs
	var all_of_set_no_longer_grabbing = false
	# Check if all	legs are no longer grabbing
	var i = 0
	for idx in active_set:
		if legs[idx].is_grabbing:
			break
		i += 1
		if i == len(active_set):
			all_of_set_no_longer_grabbing = true
	
	# Reset should grabbing
	if all_of_set_no_longer_grabbing:
		is_set_1_grabbing = !is_set_1_grabbing
		for leg_index in set_1_legs:
			legs[leg_index].should_grab = is_set_1_grabbing
		for leg_index in set_2_legs:
			legs[leg_index].should_grab = !is_set_1_grabbing
		
				

	
	# Compute cross between forward and target	
	var forward = Vector2.RIGHT.rotated(global_rotation)
	var cros = forward.cross((target.global_position - global_position).normalized())
	var should_turn_counterclockwise = true if cros > 0 else false
					
	# Free legs move to position for next step	
	for leg in legs:
		if !leg.is_grabbing:
			leg.set_ik_leg_target_for_step(target.global_position, should_turn_counterclockwise)	
	

	
	
	
	
	if true or Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		for leg in legs:
			if !leg.is_grabbing: continue
			
			# Direction of muscle
			var dir_F = leg.get_force_dir()
			
			# Grab based damping
			var projection = linear_velocity.project(dir_F)		
			var rejecion = linear_velocity - projection
			linear_velocity = projection + rejecion * (1 - delta * 0.4)
			
			
			
			#var direction_to_target = (target.global_position - leg.global_position).normalized()	
			#
			#var dot_in_dir_of_target = dir_F.project(direction_to_target).dot(direction_to_target)
			#
			#var is_not_in_right_direction = dot_in_dir_of_target <= 0
			#
##			
			#if dot_in_dir_of_target < 0:
				#if should_turn_counterclockwise and is_set_1_grabbing:
					#leg.stop_grabbing()
					#continue
				#elif not should_turn_counterclockwise and not is_set_1_grabbing:
					#leg.stop_grabbing()
					#continue
				#
			
			var F = dir_F * leg.muscle_strength * leg.get_muscle_strength_percent()
			
			vecs_to_draw.push_back([leg.global_position, leg.global_position + F.normalized() * 64, Color(1, 0, 0) if should_turn_counterclockwise else Color(0, 0,1), 2])
			
			apply_force(F, legs[0].global_position)
			
	
