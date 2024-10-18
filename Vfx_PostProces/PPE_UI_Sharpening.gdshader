// SHARPENING PIXLES
shader_type canvas_item;

// Parameters
uniform sampler2D screen_tex : hint_screen_texture, filter_nearest, repeat_disable;
uniform float pixel: hint_range(1.0, 5.0, 1.0) = 1.0;
uniform float sharpening: hint_range(0.0, 5.0, 0.01) = 0.0;

void fragment() {
	// Screen Coordinates
	vec2 coord = (1.0 / FRAGCOORD.xy) * SCREEN_UV;
	// Screen Sample
	vec3 screen = texture(screen_tex, SCREEN_UV).rgb;
	//Blur Sharp Smaple
	vec3 N = texture(screen_tex, SCREEN_UV + (coord * (vec2(0.0, pixel)))).rgb;
	vec3 S = texture(screen_tex, SCREEN_UV + (coord * (vec2(0.0, -pixel)))).rgb;
	vec3 NE = texture(screen_tex, SCREEN_UV + (coord * (vec2(pixel, pixel)))).rgb;
	vec3 SE = texture(screen_tex, SCREEN_UV + (coord * (vec2(pixel, -pixel)))).rgb;
	vec3 NW = texture(screen_tex, SCREEN_UV + (coord * (vec2(-pixel, pixel)))).rgb;
	vec3 SW = texture(screen_tex, SCREEN_UV + (coord * (vec2(-pixel,-pixel)))).rgb;
	//Combined Samples
	vec3 sample = ((N + S + NE + SE + NW + SW) / 6.0) * 0.7;
	vec3 blur_sample = clamp((screen * 0.3) + sample, 0.0, 1.0);
	//Final COLOR
	vec3 mix_sharpening = mix(screen, blur_sample, 1.0-sharpening);
	COLOR.rgb = mix_sharpening ;
}