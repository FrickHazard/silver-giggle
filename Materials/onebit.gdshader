shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture;

uniform vec4 color1 : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 color2 : source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform float threshold : hint_range(0.0, 1.0) = 0.5;

void fragment() {
    vec4 texture_color = texture(screen_texture, SCREEN_UV);

	if(texture_color.a == 0.0)
	{
		COLOR = vec4(0,0,0,0);
	}
	else {
	    float luminance = dot(texture_color.rgb, vec3(0.299, 0.587, 0.114));

	    if (luminance > threshold) {
	        COLOR = color1;
	    } else {
	        COLOR = color2;
	    }
	}
}
