//CHROMATIC ABERRATION
shader_type canvas_item;

// Texel Albedo
uniform lowp sampler2D screen_texture : hint_screen_texture, filter_nearest;

//Chromatic
uniform lowp float chromaticRedPx = 3.0;
uniform lowp float chromaticBluePx =3.0;
uniform lowp float chromaticIntensity : hint_range(0.0, 1.0) = 1.0;

uniform int _ : hint_range(0, 0) = 0; // Spacer

// Vignette
uniform float vignetteOpacity : hint_range(0.0, 1.0, 0.001)= 1.0;
uniform float vignetteSize : hint_range(0.0,1.0, 0.001) = 0.5;
uniform float vignetteFeather : hint_range(0.0,1.0, 0.001) = 0.5;
uniform vec4 vignetteColor: source_color = vec4(0,0,0,1);

void fragment() {
	
	//	Chromatic
	float chromaticGreenPx = 1.0;
	float r = texture(screen_texture, SCREEN_UV + vec2(SCREEN_PIXEL_SIZE*chromaticRedPx*chromaticIntensity), 0.0).r;
	float g = texture(screen_texture, SCREEN_UV + vec2(SCREEN_PIXEL_SIZE*chromaticGreenPx), 0.0).g;
	float b = texture(screen_texture, SCREEN_UV + vec2(SCREEN_PIXEL_SIZE*(-chromaticBluePx)*chromaticIntensity), 0.0).b;
	COLOR.rgb = vec3(r, g, b);
	
	//	Vignette
	float distCenter = distance(UV, vec2(0.5));
	float mask = smoothstep(vignetteSize*0.5, (vignetteFeather*0.5)+0.5, distCenter) * vignetteOpacity;
	COLOR.rgb *= (vignetteColor.rgb*mask)+(1.0-mask);
	
}