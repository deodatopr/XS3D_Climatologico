//UI BlurredBack
shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;
uniform vec4 color : source_color = vec4 (1,1,1,1);
uniform float brightness: hint_range(0.0, 1.0, 0.001) = 0.5;
uniform int blur : hint_range(1, 13) = 1;

void fragment() {
	vec3 Dark = COLOR.rgb = textureLod(screen_texture, SCREEN_UV, float(blur)).rgb * 0.25;
	vec3 Bright = COLOR.rgb = textureLod(screen_texture, SCREEN_UV, float(blur)).rgb + 0.25;
	COLOR.rgb = mix(Dark, Bright, brightness) * color.rgb;
}
