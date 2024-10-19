extends RigidBody2D

@export var target: Node2D;
@export var max_speed = 200
@export var max_angular_velocity = 200

@export var legs : Array[SegmentLeg] = [];

@export var leg_grab_abandon_angle = deg_to_rad(140)
	
	
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
var set_1_legs = [0]
var set_2_legs = [1]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if is_set_1_grabbing:
		legs[0].should_grab = true
	else: 
		legs[1].should_grab = true


var vecs_to_draw = []
func _draw():
	#draw_vector(Vector2(0,0), Vector2(600, 0), Color(1, 1, 0), 20)
	#var leg_groups = [
		#[legs[0], legs[1]],
		#[legs[2], legs[3]],
		#[legs[4], legs[5]]
	#]
	#for leg_g in leg_groups:
		#if leg_g[0].target_pos and leg_g[1].target_pos:
			#draw_line(to_local(leg_g[0].target_pos), to_local(leg_g[1].target_pos), Color(1,1,1), 10, true)
			
	for vec in vecs_to_draw:
		draw_vector(to_local(vec[0]), to_local(vec[1]), vec[2], vec[3])
	vecs_to_draw = []
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	queue_redraw()
	
	linear_velocity *= (0.9);
	
	var direction_to_target = (target.global_position - global_position).normalized()	
	
	for leg_index in (set_1_legs if is_set_1_grabbing else set_2_legs):
		if !legs[leg_index].is_grabbing:
			is_set_1_grabbing = !is_set_1_grabbing
			if is_set_1_grabbing:
				legs[0].should_grab = true
				legs[1].should_grab = false
			else:
				legs[0].should_grab = false
				legs[1].should_grab = true
			
	#for leg in legs:
		#if leg.is_grabbing and leg.should_grab:
			#var dir_F = (legs[0].global_position - legs[0].get_node("./Femur/Tibia").global_position).normalized()
			#dir_F = Vector2(dir_F.y, -dir_F.x)
			#if dir_F.angle_to(direction_to_target) > leg_grab_abandon_angle:
				#leg.is_grabbing = false
		
	
	for leg in legs:
		if !leg.is_grabbing:
			leg.set_ik_leg_target_for_step(target.global_position)
		#var leg1 = leg_g[0]
		#var leg2 = leg_g[1]
		#var segment_c =  (leg1.global_position + leg2.global_position)/2
		#var target_to_leg = (target.global_position  - segment_c).normalized()
		#var cros = Vector2(-target_to_leg.y, target_to_leg.x)
		#leg1.target_pos = leg1.global_position + cros * 100  * -1
		#leg2.target_pos = leg2.global_position + cros * 100 * 1
	
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		for leg in legs:
			if !leg.is_grabbing: continue
			
			var dir_F = leg.get_force_dir()
			
			var F = dir_F * leg.muscle_strength
			
			vecs_to_draw.push_back([leg.global_position, leg.global_position + F * 40, Color(1, 0, 0), 10])
			
			apply_force(F, legs[0].global_position)
			
	
