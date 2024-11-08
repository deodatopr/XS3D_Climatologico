shader_type canvas_item;

uniform sampler2D screen_texture: hint_screen_texture, filter_linear_mipmap;
uniform float intensity: hint_range(0.01, 1, 0.01) = 0.25;
uniform float speed: hint_range(0.01, 1.0, 0.01) = 0.5;
uniform sampler2D noiseMap:repeat_enable;

void fragment() {
	vec3 noiseMapOffset = texture( noiseMap, SCREEN_UV + TIME * vec2(0, speed * 0.2) ).rgb;
	vec3 texelColor = texture(screen_texture, SCREEN_UV +  (noiseMapOffset.r * (intensity * 0.05))).rgb;
	COLOR.rgb = texelColor;
}
