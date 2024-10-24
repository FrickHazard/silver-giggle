extends Node

func _ready():
	SignalBus.switch_day_state.connect(_on_day_state_changed)

func _on_day_state_changed(new_state):
	match new_state:
		SignalBus.DaylightState.MORNING:
			print("It's morning!")
		SignalBus.DaylightState.DAY:
			print("It's daytime!")
		SignalBus.DaylightState.EVENING:
			print("It's evening!")
		SignalBus.DaylightState.NIGHT:
			print("It's night!")
