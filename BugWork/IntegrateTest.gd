extends RigidBody2D

class_name ChildAnchor


var thrust = Vector2(0, 10)
var torque = 10

func _ready() -> void:
	linear_damp = 0
	angular_damp = 0


var recorded = null	


func _physics_process(delta):
	if Input.is_key_pressed(KEY_E) and recorded:
		recorded = Vector2(0, 20)
		apply_central_force(recorded)

func _integrate_forces(state):
	if state.linear_velocity.length() > 0:
		print(state.linear_velocity)
	if recorded:
		state.apply_central_force(-recorded)
		recorded = null
	#state.apply_central_impulse(-state.linear_velocity)
	# state.linear_velocity = Vector2(0,0)
	#print(state.total_applied_force)
	#pass
	#state.apply_central_force(-state.linear_velocity)
	#var v = linear_velocity
	#var agg = Vector2(v.x, v.y)
	#
	#var u = agg.project(Vector2.UP)
	#agg -= Vector2.UP * max(min(10, u.length()), 0)
	#
	#var r = agg.project(Vector2.RIGHT)
	#agg -= Vector2.RIGHT * max(min(10, r.length()), 0)
	#
	#state.apply_force(agg - v)
	#
	#
	#if true:
		#state.apply_force(thrust.rotated(rotation))
	#else:
		#state.apply_force(Vector2())
	#var rotation_direction = 0
	#if Input.is_action_pressed("ui_right"):
		#rotation_direction += 1
	#if Input.is_action_pressed("ui_left"):
		#rotation_direction -= 1
	#state.apply_torque(rotation_direction * torque)
	#
	
	
	
