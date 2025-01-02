shader_type spatial;
render_mode unshaded;

uniform sampler2D albedo;
uniform vec3 emmissionColor: source_color;
uniform float energyMultiplier: hint_range(0.0, 16.0, 0.01) = 2.5;

void vertex() {
	vec3 dir = CAMERA_POSITION_WORLD - NODE_POSITION_WORLD;
	dir.y = 0.0;
	dir = normalize(dir);
	
	mat3 rot = mat3(cross (vec3(0.0,1.0,0.0),dir), vec3(0.0,1.0,0.0),dir);
	VERTEX = rot*VERTEX;
	NORMAL = dir;
}

void fragment() {
	// Called for every pixel the material is visible on.
	vec4 texAlbedo = texture(albedo,UV);
	
	ALBEDO = texAlbedo.rgb * emmissionColor * energyMultiplier;
	ALPHA = texAlbedo.a;
	
	
}
