shader_type canvas_item;

uniform sampler2D noise_texture : hint_default_black; // Pre-calculated noise texture
uniform float noise_scale : hint_range(0.0, 10.0) = 5.0; // Scale of the noise
uniform float noise_strength : hint_range(0.0, 1.0) = 0.05; // Strength of the noise effect
uniform float displacement_strength : hint_range(0.0, 1.0) = 0.1; // Strength of the displacement effect
uniform float wave_frequency : hint_range(0.0, 10.0) = 5.0; // Frequency of the wavy effect
uniform float wave_amplitude : hint_range(0.0, 1.0) = 0.1; // Amplitude of the wavy effect

void fragment() {
    vec2 uv = UV;

    // Calculate UV for the noise texture
    vec2 noise_uv = uv * noise_scale;

    // Sample from the noise texture
    float n = texture(noise_texture, noise_uv).r; // Assuming the noise texture is grayscale

    // Modify the UV coordinates using sampled noise for displacement
    uv.x += n * noise_strength;
    uv.y += n * noise_strength;

    // Introduce oscillating displacement
    float time_based_displacement = sin((TIME + uv.y) * wave_frequency) * wave_amplitude; // Oscillating effect
    uv.x += time_based_displacement;

    // Sample the main texture at the distorted UV
    vec4 color = texture(TEXTURE, uv);

    // Set the final color
    COLOR = color;
}
