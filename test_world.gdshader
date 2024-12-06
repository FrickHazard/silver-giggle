shader_type canvas_item;

uniform vec4 tint = vec4(1.0, 1.0, 1.0, 1.0);
uniform sampler2D screen_texture : hint_screen_texture;

void fragment() {
    vec4 color = texture(screen_texture, SCREEN_UV); // Use the screen texture uniform
    color = mix(color, tint, 0.4); // Blend the screen texture with the tint
    color = mix(vec4(0.5), color, 0.5); // Further blend with a gray tone
    COLOR = color;
}
