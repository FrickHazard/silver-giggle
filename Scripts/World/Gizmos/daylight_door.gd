extends Node2D

@export var open_trigger: SignalBus.DaylightState
@export var close_trigger: SignalBus.DaylightState

@export var door_collider: CollisionShape2D
@export var door_visual: Sprite2D

func _ready():
	SignalBus.switch_day_state.connect(_on_day_state_changed)

func _on_day_state_changed(new_state):
	if new_state == open_trigger:
		_open_door()
	elif new_state == close_trigger:
		_close_door()
	pass
	
func _open_door():
	door_collider.disabled = true
	door_visual.visible = false
	#play noise
	#play animation
	pass
	
func _close_door():
	door_collider.disabled = false
	door_visual.visible = true
	#play noise
	#play animation
	pass
