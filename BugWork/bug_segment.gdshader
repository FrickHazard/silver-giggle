shader_type canvas_item;

uniform float time_offset = 1.f;
uniform float amplitude_px = 10.0f;
uniform float frequancy_px = 10.0f;
uniform float time_scale = 0.5f;


void vertex() {

	VERTEX.y += amplitude_px * sign(VERTEX.y) * (0.5 + 0.5 * sin(((TIME + time_offset) * time_scale + VERTEX.x) * frequancy_px));
	// Called for every vertex the material is visible on.
}

void fragment() {
	// Called for every pixel the material is visible on.
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
