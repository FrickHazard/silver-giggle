extends RigidBody2D

@export var target: Node2D;
@export var max_velocity = 200.0
@export var max_angular_velocity = 0.8
@export var rejection_damping = 0.3
@export var away_from_target_damping = 2
@export var angular_damping = 6
@export var set_1_legs: Array[SegmentLeg] = []
@export var set_2_legs: Array[SegmentLeg] = []

var draw_debug_info = true
	
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

# Calculate velocity at a specific point on a rigid body
func get_point_velocity(point: Vector2) -> Vector2:
	var body_to_point = point - global_position  # Vector from center of mass to the point
	var rotational_velocity = Vector2(-body_to_point.y, body_to_point.x) * angular_velocity
	return linear_velocity + rotational_velocity

func zip():
	pass
	## Concatenate legs together	
	#legs = left_legs + right_legs
	## Zipper based on how some insects us every other leg on each side to push themselves forward
	#var is_set_1_turn = true
	#var set_1_is_left = true
	#var set_2_is_left = false
	#var left_index = 0
	#var right_index = 0
	#while left_index < len(left_legs) or right_index < len(right_legs):
		#if is_set_1_turn:
			#if (set_1_is_left and left_index < len(left_legs)) or right_index == len(right_legs):
				#set_1_legs.append(left_index)
				#left_index += 1
				#set_1_is_left = !set_1_is_left
			#else: 
				#set_1_legs.append(right_index + len(left_legs))
				#right_index += 1
				#set_1_is_left = !set_1_is_left
		#else:
			#if (set_2_is_left and left_index < len(left_legs)) or right_index == len(right_legs):
				#set_2_legs.append(left_index)
				#left_index += 1
				#set_2_is_left = !set_2_is_left
			#else: 
				#set_2_legs.append(right_index + len(left_legs))
				#right_index += 1
				#set_2_is_left = !set_2_is_left
		#is_set_1_turn = !is_set_1_turn

var is_set_1_grabbing = true

var legs = []
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Concatenate legs together	
	legs = set_1_legs + set_2_legs		 
	# Intialize who is grabbing first	
	for leg in set_1_legs:
		leg.should_grab = true
		leg.is_pushing = is_set_1_grabbing
	
	for leg in set_2_legs:
		leg.should_grab = true
		leg.is_pushing = !is_set_1_grabbing
	
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
	
	if Input.is_key_pressed(KEY_SPACE):
		for leg in legs:
			leg.release_grip()
		_ready()
	
	# Alternte between legs	
	var active_set = set_1_legs if is_set_1_grabbing else set_2_legs
	var all_of_set_no_longer_grabbing = false

	# Check if all	legs are no longer grabbing
	var i = 0
	for leg in active_set:
		if leg.is_pushing:
			break
		i += 1
		if i == len(active_set):
			all_of_set_no_longer_grabbing = true

	# Reset should grabbing
	if all_of_set_no_longer_grabbing:
		is_set_1_grabbing = !is_set_1_grabbing
		for leg in set_1_legs:
			if not is_set_1_grabbing: leg.release_grip()
			leg.should_grab = true
			leg.is_pushing = is_set_1_grabbing
		for leg in set_2_legs:
			if is_set_1_grabbing: leg.release_grip()
			leg.should_grab = true
			leg.is_pushing = !is_set_1_grabbing
		
	# Compute cross between forward and target	
	var forward = Vector2.RIGHT.rotated(global_rotation)
	var cros = forward.cross((target.global_position - global_position).normalized())
	var should_turn_counterclockwise = false if cros > 0 else true
	should_turn_counterclockwise = true
					
	# Free legs move to position for next step	
	for leg in legs:
		if !leg.is_grabbing:
			leg.set_ik_leg_target_for_step(target.global_position, should_turn_counterclockwise)	
	
	var direction_to_target = (target.global_position - global_position).normalized()
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		for leg in legs:
			
			if leg.is_grabbing:
				var absorb_force = leg.absorb_force(get_point_velocity(leg.global_position))
				apply_force(absorb_force, leg.global_position)
				vecs_to_draw.push_back([leg.global_position, leg.global_position + absorb_force, Color(1, 1, 0), 2])
			
			if leg.is_grabbing and leg.is_pushing:
				var dir_F = leg.get_force_dir()
				var F = dir_F * leg.muscle_strength * leg.get_muscle_strength_percent()
				apply_force(F, leg.global_position)
			
			# Direction of muscle
			
					
			# Grab based damping
			#var projection = linear_velocity.project(dir_F)		
			#var rejecion = linear_velocity - projection
#			# Dampen force not on axis to target
			#linear_velocity = projection + rejecion * (1 - delta * rejection_damping)			
			# Dampen force awy from target
			#if linear_velocity.normalized().dot(direction_to_target) < 0:
				#linear_velocity *= (1 + linear_velocity.normalized().dot(direction_to_target) * delta * away_from_target_damping)
			
			## Grab based angular damping
			#var future_angular = forward.rotated(sign(angular_velocity))
			#if direction_to_target.dot(forward) > direction_to_target.dot(future_angular):
				#angular_velocity = angular_velocity * (1 - delta * angular_damping)
			
			# Leg force			
			
			
			#vecs_to_draw.push_back([leg.global_position, leg.global_position + F.normalized() * 64, Color(1, 0, 0) if should_turn_counterclockwise else Color(0, 0,1), 2])
	
	if abs(angular_velocity) > max_angular_velocity:
		angular_velocity = sign(angular_velocity) * max_angular_velocity
	
	if linear_velocity.length() > max_velocity:
		linear_velocity = linear_velocity.normalized() * max_velocity
	
