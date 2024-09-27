shader_type spatial;

const float S = 8.f;

void vertex() {
	// Called for every vertex the material is visible on.
	VERTEX.y += 0.3 * cos(VERTEX.x * S + sin(TIME)) * sin(VERTEX.z * S+ sin(TIME));
}

void fragment() {
	ALBEDO.r = UV.x * (0.5 + 0.5 * sin(TIME));
	ALBEDO.g = UV.y * (0.5 + 0.5 * cos(TIME));
	ALBEDO.r += NORMAL.x;
	ALBEDO.b += NORMAL.y;
	// Called for every pixel the material is visible on.
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
