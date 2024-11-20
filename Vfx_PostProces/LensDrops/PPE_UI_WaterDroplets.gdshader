shader_type canvas_item;

uniform float tile = 5.0;
uniform float speed = 2.0;
uniform float wiggle = 2.0;
uniform float refraction = 0.05;
uniform float fogginess = 0.0;
uniform float drop_Radious = 0.05;
uniform float drop_Strength = 1.0;
uniform float trail_Strength = 1.0;

uniform int layers = 1;
uniform sampler2D screen_texture: hint_screen_texture, filter_linear_mipmap;

float RandomNumber(vec2 seed){
	seed = fract(seed * vec2(123.456, 234.789));
	seed += dot(seed,seed +34.73);
	return fract(seed.x * seed.y);
}

vec2 RainDrops(vec2 uv,float _tile, float _speed, float _wiggle){
	uv.x *= 1.9;
	float t = TIME * _speed;
	float original_y = (1.0 - uv.y) * 0.3 + 0.7;
	float w = uv.y * _wiggle;
	
	uv *= _tile;
	uv.y -= t*0.25;
	
	vec2 gridUV = fract(uv) - 0.5;
	vec2 uvId = floor(uv);
	
	float rand_num = RandomNumber(uvId / (_tile * 2.0));
	t+=rand_num * TAU;
	w+=rand_num;
	
	float radious = drop_Radious * original_y;
	float drop_Offs = 0.5 - radious;
	float x = (rand_num - 0.5) * drop_Offs;
	x += sin(w  + cos(w * 4.0) * pow(sin(w),2.0)) * (drop_Offs - abs(x));
	float y = cos(t + cos(t + cos(t)*0.5)) * drop_Offs;
	//Shape of Drop
	y += (gridUV.x-x) * (gridUV.x-x) * -3.0;
	
	vec2 dropPos = gridUV - vec2(x,y);
	float drop = smoothstep(radious,0.01,length(dropPos));
	
	
	float trail =  smoothstep(radious,-radious,dropPos.y);
	trail *= smoothstep(radious,0.01,abs(dropPos.x));
	trail *= smoothstep(-0.5,y, gridUV.y);
	
	vec2 output = vec2(0);
	output += drop * drop_Strength * original_y;
	output += trail* trail_Strength * refraction;
	//if (gridUV.x > 0.48 || gridUV.y > 0.48) output.r = 1.0;
	//output = vec2(original_y);
	return output *dropPos * refraction;
}

void fragment() {
	vec2 droplets = vec2(0);
	for(int i = 1; i<= layers;i++){
		droplets += RainDrops(UV,tile  * float(i),speed  * float(i),wiggle * float(i));
	}
	COLOR.rgb = textureLod(screen_texture,SCREEN_UV - droplets,smoothstep(.001,.0001,abs(droplets.x)) * fogginess).rgb;
}

