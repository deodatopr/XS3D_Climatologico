// PIN ALARM (CIRCULAR DISTORTION)
shader_type canvas_item;

// Parameters
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform float distort: hint_range(0.0, 0.1, 0.001) = 0.05;
uniform float chromatic: hint_range(0.0, 0.1, 0.01) = 0.025;
uniform float smoothness: hint_range(0.05, 0.2, 0.01) = 0.15;
uniform int stop : hint_range(0, 1) = 1;
uniform float speed: hint_range(0.0, 2.0, 0.001) = 0.4;
uniform bool isCritico = false;
uniform vec4 colorCritico: source_color = vec4(0.3,0.0,0.0,0.04);
uniform float smoothnessCrit: hint_range(0.05, 0.2, 0.01) = 0.1;

void fragment() {
	float radius = 0.1;

	if (stop == 1){
		radius = fract(TIME*speed);
	}else{
		radius = fract(speed);
	}

	vec2 center = vec2(0.5, 0.5);
	vec2 st = SCREEN_UV;
	float aspect_ratio = SCREEN_PIXEL_SIZE.y/SCREEN_PIXEL_SIZE.x;
	vec2 scaled_st = (st -vec2(0.0, 0.5)) / vec2(1.0, aspect_ratio) + vec2(0,0.5);
	vec2 dist_center = scaled_st - center;
	float mask;
	if (isCritico){
		mask =  (1.0 - smoothstep(radius-smoothnessCrit, radius, length(dist_center))) * smoothstep(radius - distort - smoothnessCrit, radius-distort , length(dist_center));
	}
	else{
		mask =  (1.0 - smoothstep(radius-smoothness, radius, length(dist_center))) * smoothstep(radius - distort - smoothness, radius-distort , length(dist_center));
	}

	vec2 offset = normalize(dist_center)*chromatic*mask;
	vec2 biased_st = scaled_st - offset;
	vec2 abber_vec = offset*mask;
	vec2 final_st = st*(1.0-mask) + biased_st*mask;
	vec4 red = texture(SCREEN_TEXTURE, final_st + abber_vec);
	vec4 blue = texture(SCREEN_TEXTURE, final_st - abber_vec);
	vec4 ori = texture(SCREEN_TEXTURE, final_st);

	if (isCritico){
		COLOR = mix(vec4(red.r, ori.g, blue.b, 1.0) , colorCritico,mask);
	}
	else{
		COLOR = vec4(red.r, ori.g, blue.b, 1.0);
	}
}