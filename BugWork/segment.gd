extends RigidBody2D

@export var target: Node2D;
@export var max_velocity = 200.0
@export var max_angular_velocity = 0.8
@export var set_1_legs: Array[SegmentLeg] = []
@export var set_2_legs: Array[SegmentLeg] = []

var v0 = Vector2(0,0)
var r0 = 0
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
# https://github.com/godotengine/godot/blob/efa144396d8003c4b3021bca8242ce5cda4d131f/modules/godot_physics_2d/godot_body_2d.h#L321
func get_force_at_point(point: Vector2, lin_vel: Vector2, a_vel: float) -> Vector2:
	var rel_pos = point - global_position  # Vector from center of mass to the point
	return lin_vel + Vector2(-a_vel * rel_pos.y, a_vel * rel_pos.x);

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

var is_set_1_reaching = true
var legs = []
var is_initializing = true

func get_inertiaR():
	return 1.0 / PhysicsServer2D.body_get_direct_state(get_rid()).inverse_inertia	

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	is_initializing = true
	freeze = true	
	legs = set_1_legs + set_2_legs
	for leg in set_1_legs:
		leg.leg_state = SegmentLeg.LegState.REACHING
	for leg in set_2_legs:
		leg.leg_state = SegmentLeg.LegState.REACHING
	
var vecs_to_draw = []
func _draw():
	if not draw_debug_info:
		vecs_to_draw = []
		return
	for vec in vecs_to_draw:
		draw_vector(to_local(vec[0]), to_local(vec[1]), vec[2], vec[3])
	vecs_to_draw = []

func transition_legs():
	if is_initializing: return
	
	# Alternte between legs	
	var active_set = set_1_legs if is_set_1_reaching else set_2_legs
	var all_of_reaching_set_grabbing = false
	# Check if all	legs are no longer grabbing
	var i = 0
	for leg in legs:
		if leg.leg_state != SegmentLeg.LegState.STANDING or not leg.is_grabbing:
			break
		i += 1
	if i == len(legs):
		all_of_reaching_set_grabbing = true
	# Reset should grabbing
	if all_of_reaching_set_grabbing:
		is_set_1_reaching = !is_set_1_reaching
		for leg in set_1_legs:
			if is_set_1_reaching:
				leg.release_grip()
				leg.leg_state = SegmentLeg.LegState.REACHING
				leg.set_ik_leg_target_for_step(heading_point, global_position, global_rotation)
			else:
				leg.leg_state = SegmentLeg.LegState.STANDING
		for leg in set_2_legs:
			if not is_set_1_reaching:
				leg.release_grip()
				leg.leg_state = SegmentLeg.LegState.REACHING
				leg.set_ik_leg_target_for_step(heading_point, global_position, global_rotation)
			else:
				leg.leg_state = SegmentLeg.LegState.STANDING
	

func _input(ev):
	if Input.is_key_pressed(KEY_K):
		pass
		# transition_legs()

var heading_point = Vector2(0,0)
func compute_heading_point():
	# Compute cross between forward and target
	var vec_to_target = (target.global_position - global_position)
	var forward = Vector2.RIGHT.rotated(global_rotation)
	# Heading logic
	var angle = clamp(forward.angle_to(vec_to_target), -PI/6, PI/6)
	heading_point = global_position + (forward.rotated(angle) * min(64, vec_to_target.length()))
	vecs_to_draw.append([global_position, heading_point, Color(0, 1, 0), 5])


func _physics_process(delta):
	queue_redraw()
	
	if Input.is_key_pressed(KEY_E):
		apply_force(Vector2(0, 20))
	
	if Input.is_key_pressed(KEY_SPACE):
		for leg in legs:
			leg.release_grip()
		_ready()
	
	if is_initializing:
		var i = 0
		for leg in legs:
			if not leg.is_grabbing or leg.leg_state != SegmentLeg.LegState.STANDING: break
			i += 1
		if i == len(legs):
			is_initializing = false
			freeze = false	
		
	compute_heading_point()
					
	# Free legs move to position for next step	
	for leg in legs:
		if leg.leg_state == SegmentLeg.LegState.REACHING:
			leg.set_ik_leg_target_for_step(heading_point, global_position, global_rotation)
	transition_legs()

var internal_forces = []
func apply_internal_force(state: PhysicsDirectBodyState2D, force: Vector2, position: Vector2):
	# https://github.com/godotengine/godot/blob/33957aee69683cf1f542a8622e5a9efd23070f1c/servers/physics_2d/godot_body_2d.h#L256
	var torque = (position - center_of_mass).cross(force);
	internal_forces.append([force, torque])
	state.apply_force(force, position)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	# Compute external acceleration	
	var acc  = (state.linear_velocity  - v0) / state.step
	# Compute external angular acceleration	https://docs.godotengine.org/en/stable/classes/class_rigidbody2d.html#class-rigidbody2d-property-inertia
	var racc = ((state.angular_velocity - r0) / state.step) * get_inertiaR()
	
	# Forward	
	for leg in legs:
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
			if leg.is_grabbing and leg.leg_state == SegmentLeg.LegState.STANDING:
				var dir_F = leg.get_force_dir()
				var force = dir_F * leg.muscle_strength
				var torque = (leg.global_position - global_position).cross(force)
				state.angular_velocity += torque / get_inertiaR()
				state.linear_velocity += force

	# Leg torque straightening	
	for leg in legs:
		if leg.is_grabbing and leg.grabbed_pos != null:
			var grabbed_pos_target = leg.get_straight_grabbed_pos()
			var force = (leg.grabbed_pos - grabbed_pos_target).normalized() * min(0.5, (leg.grabbed_pos - grabbed_pos_target).length()  / state.step)
			var torque = (grabbed_pos_target - global_position).cross(force)
			state.angular_velocity += torque / get_inertiaR()
			state.linear_velocity += force
	
	# Constraint and absorb pass	
	for leg in legs:
		if leg.is_grabbing and leg.grabbed_pos != null:
			var r = (leg.global_position - global_position).rotated(angular_velocity * state.step)
			var future_leg_position = global_position + r + state.linear_velocity * state.step
			var displacement_from_leg_constraint = (leg.grabbed_pos - future_leg_position).length() - leg.get_rigid_length()
			if displacement_from_leg_constraint <= 0: continue
			var correction_velocity = ((leg.grabbed_pos - leg.global_position).normalized() * displacement_from_leg_constraint / state.step)
			var torque = (future_leg_position - global_position).cross(correction_velocity)
			state.angular_velocity += torque / get_inertiaR()
			state.linear_velocity += correction_velocity
		
		#if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
			#if leg.is_grabbing and leg.leg_state == SegmentLeg.LegState.PUSHING:
				#var dir_F = leg.get_force_dir()
				#var F = dir_F * leg.muscle_strength * leg.get_muscle_strength_percent()
				#apply_force(F, leg.global_position)
		
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
	
	#if abs(angular_velocity) > max_angular_velocity:
		#angular_velocity = sign(angular_velocity) * max_angular_velocity
	#
	#if linear_velocity.length() > max_velocity:
		#linear_velocity = linear_velocity.normalized() * max_velocity
	v0 = state.linear_velocity
	r0 = state.angular_velocity	
