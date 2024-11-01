extends Light2D

var initial_scale: float
var max_scale: float
var is_shrink: bool = false
var scale_speed: float = 0.5  # Adjust this to control speed of scaling

func _ready() -> void:
	initial_scale = scale.x
	max_scale = scale.x * 1.1

func _process(delta: float) -> void:
	if is_shrink:
		scale.x = lerp(scale.x, initial_scale, delta * scale_speed)
		scale.y = lerp(scale.y, initial_scale, delta * scale_speed)
		if scale.x <= initial_scale + 0.01:
			is_shrink = false
	else:
		scale.x = lerp(scale.x, max_scale, delta * scale_speed)
		scale.y = lerp(scale.y, max_scale, delta * scale_speed)
		if scale.x >= max_scale - 0.01:
			is_shrink = true
