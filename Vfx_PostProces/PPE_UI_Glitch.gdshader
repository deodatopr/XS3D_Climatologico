//GLITCH

shader_type canvas_item;

uniform bool random = false;
uniform float random_rate : hint_range( 0.0, 1.0 ) = 0.2;
uniform float rows_min : hint_range( 1, 50,1) = 5;
uniform float rows_max : hint_range( 1, 50,1) = 20;
uniform float rows_speed : hint_range( 50, 100) = 70;
uniform float chromatic : hint_range( 0.0, 1 ) = 0.5;
uniform float intensity : hint_range( 0.0, 1.0 ,.01) = 0.3;

uniform sampler2D screen_texture : hint_screen_texture;

//func random
float randomSeed( float seed ) { return fract( 543.2543 * sin( dot( vec2( seed, seed ), vec2( 3525.46, -54.3415 ) ) ) ); }

void fragment( )
{
	//Toggle random rate
	float enable_shift = 0.0;
	if (random)
		enable_shift = float(randomSeed( trunc( TIME * 5.0 ) ) < random_rate);
	else
		enable_shift = 1.0;
	
	//Random Rows
	float random_rows = float(randomSeed( trunc( TIME * 5.0 ) )) * rows_speed;
	random_rows = clamp(random_rows,rows_min,rows_max);
	
	//Render Texture
	vec2 fixed_uv = SCREEN_UV;
	fixed_uv.x += (
		randomSeed(
			( trunc( SCREEN_UV.y * (random_rows) ) / random_rows )
		+	TIME
		) - 0.5
	) * ((intensity * 0.1)+ 0.01) * enable_shift;

	//Final Render
	vec4 pixel_color = textureLod( screen_texture, fixed_uv, 0.0 );
	pixel_color.r = mix(
		pixel_color.r
	,	textureLod( screen_texture, fixed_uv + vec2( chromatic * .02, 0.0 ), 0.0 ).r
	,	enable_shift
	);
	pixel_color.b = mix(
		pixel_color.b
	,	textureLod( screen_texture, fixed_uv + vec2( -chromatic * .02, 0.0 ), 0.0 ).b
	,	enable_shift
	);
	COLOR = pixel_color;
}
