extends Polygon2D

func _process(delta):
	if material:
		# Assuming the material is a ShaderMaterial
		var shader_material = material as ShaderMaterial
		shader_material.set_shader_parameter("scale", scale)
		shader_material.set_shader_parameter("world_position", global_position)
