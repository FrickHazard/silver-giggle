extends Polygon2D

class_name SegmentLeg

var EPS = 10

# Joint constraints in radians
@export var shoulder_min = deg_to_rad(-60.0) # fowrard angle limit
@export var shoulder_max = deg_to_rad(60.0) # backward angle limit

@export var elbow_min = deg_to_rad(-100.0)   # fowrard angle limit
@export var elbow_max = deg_to_rad(100.0)  # backward angle limit

@export var shoulder_rotate_speed = 8
@export var elbow_rotate_speed = 8

@export var muscle_strength: float = 32.5

var physics_fps = ProjectSettings.get_setting("physics/common/physics_ticks_per_second")
var tick_count_for_release = 0
@export var time_sec_before_release = 3


var should_grab = false
# Target to reach (set this to a position in your scene)
var target_pos = null
var is_grabbing: bool = false
var is_pushing: bool = false
var grabbed_pos = null

var draw_debug_info = false

func finish_push() -> void:
	is_pushing = false

func release_grip() -> void:
	should_grab = false
	is_grabbing = false
	is_pushing = false
	grabbed_pos = null
	tick_count_for_release = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#Engine.time_scale = 0.1
	pass # Replace with function body.
	
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

var vecs_to_draw = []
var circle_buf = []
func _draw() -> void:
	if not draw_debug_info:
		vecs_to_draw = []
		circle_buf= []
		return
	if target_pos:
		draw_circle(to_local(target_pos), 3, Color(1, 0, 1))
	if grabbed_pos:
		draw_circle(to_local(grabbed_pos), 3, Color(1, 1, 0))
	for c in circle_buf:
		draw_circle(to_local(c[0]), c[1], c[2])
	circle_buf = []
	for vec in vecs_to_draw:
		draw_vector(to_local(vec[0]), to_local(vec[1]), vec[2], vec[3])
	vecs_to_draw = []

func _process(delta):
	if target_pos == null:
		return		
	queue_redraw()
	# If we are grabbed make that the target	
	var target = grabbed_pos if grabbed_pos != null else target_pos	
		
	# Update the IK every frame
	var l1 = (global_position -  $Femur/Tibia.global_position).length()
	var l2 = ($Femur/Tibia.global_position - $Femur/Tibia/Hand.global_position).length()
	var ik_result = solve_ik(Vector2(0,0), to_local(target), l1, l2)
	
	if ik_result:
		var angle1 = ik_result[0]
		var angle2 = ik_result[1]
		var actual_target = to_global(ik_result[2])
		
		circle_buf.push_back([actual_target, 3, Color(0, 1, 0)])
		
		# If we are grabbing then we assume external forces are rotating our joints freely		
		var grab_speed_modifier = 10000 if is_grabbing else 1
		
		$Femur.rotation = rotate_toward($Femur.rotation, angle1, delta * shoulder_rotate_speed * grab_speed_modifier)
		$Femur/Tibia.rotation = rotate_toward($Femur/Tibia.rotation, angle2, delta * elbow_rotate_speed * grab_speed_modifier)
		
		# Check how far off we are from grabbed pos or actual target		
		var p = grabbed_pos if grabbed_pos != null else actual_target
		
		if p.distance_to($Femur/Tibia/Hand.global_position) < EPS:		
			if should_grab and not is_grabbing:
				tick_count_for_release = 0
				is_grabbing = true
				grabbed_pos = actual_target
		elif is_grabbing:
			pass
			#finish_push()		
			
		# Leg is stretched out too far so there is no more force to be had		
		if 	is_grabbing and get_muscle_strength_percent() < 0.05:
			finish_push()
			is_grabbing = false
			grabbed_pos = null
			
			
			
		# Time for this leg
		if is_grabbing and tick_count_for_release >= physics_fps * time_sec_before_release:
			finish_push()
			is_grabbing = false
			grabbed_pos = null
			
							
		if is_grabbing:
			tick_count_for_release += 0

		$Femur/Tibia/TibiaVisual.modulate = Color(0, 0, 30, 1) if is_pushing and is_grabbing else Color(30, 0, 0, 1) if is_grabbing else Color(1, 1, 1, 1)

func absorb_force(force_at_joint: Vector2):
	if not is_grabbing:
		return Vector2(0, 0)
	var k = 2
	var l1 = (global_position -  $Femur/Tibia.global_position).length()
	var l2 = ($Femur/Tibia.global_position - $Femur/Tibia/Hand.global_position).length()
	var rest_length = (l1 + l2) / 2
	
	var leg_vec = global_position - $Femur/Tibia/Hand.global_position
	var current_length = leg_vec.length()
	var dir = leg_vec.normalized()
	
	return -force_at_joint
	#return k * (current_length - rest_length) * dir
	

# Calculate where to place leg for direction of movement
func set_ik_leg_target_for_step(global_target: Vector2, is_counter_clockwise_turning: bool):
	var leg_dir = Vector2.RIGHT.rotated(global_rotation)	
	var leg_F_dir = (Vector2.UP * scale).rotated(global_rotation)	
	
	var tangent = (global_target - global_position).normalized()
	var normal1 = Vector2(tangent.y, -tangent.x)
	var normal2 = normal1 * -1
	var normal = normal1 if normal1.dot(leg_dir) > normal2.dot(leg_dir) else normal2
	
	var l1 = (global_position -  $Femur/Tibia.global_position).length()
	var l2 = ($Femur/Tibia.global_position - $Femur/Tibia/Hand.global_position).length()
	
	var normal_F_dir = normal.rotated(deg_to_rad(-90 * scale.y))
	vecs_to_draw.push_back([global_position, global_position + normal_F_dir * l1 * 3, Color(0,1,1), 5 ])
	
	var d = normal_F_dir.dot(tangent)
	# if d x<= 0:
	var rot_vec = normal.rotated(-1 * scale.y *  abs(d) if is_counter_clockwise_turning else abs(d)* scale.y)
	rot_vec = normal.rotated(-PI/2)
	vecs_to_draw.push_back([global_position, global_position + normal * l1 * 3, Color(1,0,1), 3 ])
	vecs_to_draw.push_back([global_position, global_position + rot_vec * l1 * 3, Color(0,0,1), 3 ])
	
	var v = (rot_vec + leg_F_dir + normal * (0 if d <= 0 else 1))  
	v = normal
	#v = leg_F_dir.rotated(-PI/2)

	target_pos = global_position + v.normalized() * (l1 + l2) * 0.8
	
	vecs_to_draw.push_back([global_position, target_pos, Color(1,1,1), 5 ])
	
func get_force_dir():	
	var leg_right = (Vector2.UP * scale).rotated($Femur.global_rotation)

	return leg_right

func get_muscle_strength_percent():	
	#var leg_straight_vec = (Vector2.RIGHT * scale).rotated(global_rotation)
	#var femur_vec = (Vector2.RIGHT * scale).rotated($Femur.global_rotation)
	return abs($Femur/Tibia.rotation) / (PI / 4)

# Inverse Kinematics Solver (2D two-segment arm)
func solve_ik(base_pos: Vector2, target: Vector2, length1: float, length2: float) -> Array:
	# Get the distance between the base and the target
	var distance = base_pos.distance_to(target)
	
	# Clamp the distance to within reachable range
	distance = clamp(distance, abs(length1 - length2), length1 + length2)
	
	# Law of cosines to calculate the angle at the elbow
	var cos_angle2 = (pow(length1, 2) + pow(length2, 2) - pow(distance, 2)) / (2 * length1 * length2)
	var angle2 = acos(-cos_angle2)  # Angle at the elbow (θ2)
	
	# Angle between base to target and the first segment
	var angle1_to_target = atan2(target.y - base_pos.y, target.x - base_pos.x)
	
	# Law of cosines to calculate the shoulder angle (θ1)
	var angle1_part = acos((pow(length1, 2) + pow(distance, 2) - pow(length2, 2)) / (2 * length1 * distance))
	var angle1 = angle1_to_target - angle1_part
	
	# Clamp the angles to respect joint constraints
	angle1 = clamp(angle1, shoulder_min, shoulder_max)
	angle2 = clamp(angle2, elbow_min, elbow_max)
	
	# The actual target with the constraints applied	
	var actual_target = base_pos + Vector2.RIGHT.rotated(angle1) * length1 +  Vector2.RIGHT.rotated(angle1 + angle2) * length2
	
	# Return both angles
	return [angle1, angle2, actual_target]
