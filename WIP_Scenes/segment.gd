extends Polygon2D

class_name Segment

enum SegmentType {
	Head,
	Body
}

@export var front_socket_position: Vector2 = Vector2(35, 0)
@export var back_socket_position: Vector2 = Vector2(-35, 0)
@export var front_segment: Segment;
@export var back_segment: Segment;
@export var segment_type: SegmentType = SegmentType.Body;

@export var legs : Array[SegmentLeg] = [];

@export var turn_speed_rad: float = PI / 32;
@export var speed_px: float = 20;
@export var target: Node2D

enum SegmentMessage {
	Breathing=0
}


func recieve_message(change_in_position: Vector2, change_in_rotation: float) -> void:
	position += change_in_position

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if segment_type == SegmentType.Head and target:
		
		for leg in legs:
			var c = leg.get_capacity(target.global_position)
			c[""]
		
		#var direction_to_target = (target.position - position).normalized()
		#
		#var target_angle = direction_to_target.angle()
		#
		#var angle_difference = target_angle - rotation
		#
		#angle_difference = wrapf(angle_difference, -PI, PI)
			#
		#var new_rotation = rotate_toward(rotation, angle_difference,turn_speed_rad * delta)
		#var new_position = position + delta * direction_to_target * speed_px
		#
		#var change_in_position = new_position - position
		#var change_in_rotation = new_rotation - rotation
		#
		#rotation = new_rotation
		#position = new_position
		#
		#if back_segment:
			#back_segment.recieve_message(change_in_position, change_in_rotation)
