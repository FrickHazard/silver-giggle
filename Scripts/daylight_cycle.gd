extends Node

@export var day_length_in_seconds: float = 300.0 
var current_time_of_day: float = 0.0  

@export var time_mult: float = 1.0

@export var light_node : Light2D  

var sunrise_time: float = 0.2 
var noon_time: float = 0.5     
var sunset_time: float = 0.8  

func _ready():
	set_process(true)

func _process(delta):
	update_time_of_day(delta)
	adjust_lighting()

func update_time_of_day(delta):
	current_time_of_day += (delta / day_length_in_seconds) * time_mult
	if current_time_of_day >= 1.0:
		current_time_of_day = 0.0  

func adjust_lighting():
	if current_time_of_day <= sunrise_time:
		light_node.energy = lerp(0.2, 1.0, (current_time_of_day / sunrise_time))
	elif current_time_of_day <= noon_time:
		light_node.energy = lerp(1.0, 1.5, (current_time_of_day - sunrise_time) / (noon_time - sunrise_time))
	elif current_time_of_day <= sunset_time:
		light_node.energy = lerp(1.5, 1.0, (current_time_of_day - noon_time) / (sunset_time - noon_time))
	else:
		light_node.energy = lerp(1.0, 0.2, (current_time_of_day - sunset_time) / (1.0 - sunset_time))

func set_time_of_day(time: float):
	current_time_of_day = clamp(time, 0.0, 1.0)
