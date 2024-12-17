shader_type canvas_item;

uniform vec2 grid_size_pixels = vec2(20.0, 20.0);  // Grid cell size
uniform vec4 grid_color = vec4(1.0, 1.0, 1.0, 1.0);  // Grid color (white)
uniform vec4 background_color = vec4(0.0, 0.0, 0.0, 1.0);  // Background color (black)

uniform vec2 scale = vec2(1000.0, 1000.0);
uniform vec2 world_position = vec2(0.0, 0.0);

void vertex() {
	// Called for every vertex the material is visible on.
	UV = VERTEX.xy;
}

void fragment() {
	vec2 uv = (UV * scale) + world_position.xy;

	// Calculate grid lines
	float line_x = smoothstep(0.96, 0.98, max(abs(fract(uv.x / grid_size_pixels.x)), abs(1.f - fract(uv.x / grid_size_pixels.x)) ));
	float line_y = smoothstep(0.96, 0.98, max(abs(fract(uv.y / grid_size_pixels.y)), abs(1.f - fract(uv.y / grid_size_pixels.y)) ));

	// Combine grid lines
	float grid = max(line_x, line_y);

	// Final color
	COLOR = mix(background_color, grid_color, grid);
	//COLOR = vec4(1.0, 0., 0., 1.);
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
