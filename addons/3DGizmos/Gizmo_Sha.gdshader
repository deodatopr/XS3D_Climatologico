shader_type spatial;
render_mode unshaded,cull_back, shadows_disabled, ambient_light_disabled;

// PROPERTIES
uniform vec4 basecolor : source_color = vec4(1.0);
uniform bool Wireframe = true;

// VARIABLES
const vec3 vectors[3] = {
	vec3(1.0, 0.0 ,0.0),
	vec3(0.0, 1.0 ,0.0),
	vec3(0.0, 0.0 ,1.0)
};
varying vec3 vertexCentrics;

//--------------------------------------------------------

//VERTEX SHADER
void vertex() {
	vertexCentrics = vectors[VERTEX_ID % 3];
}

//FRAGMENT SHADER
void fragment() {

	// Create Mask
	vec3 VertCoordX = dFdx(vertexCentrics);
	vec3 VertCoordY = dFdy(vertexCentrics);
	vec3 VertCoordXY  = sqrt(VertCoordX*VertCoordX + VertCoordY*VertCoordY);
	vec3 Remap = smoothstep(vec3(0.0), VertCoordXY,vertexCentrics);
	float Mask = min(min(Remap.x, Remap.y), Remap.z);

	// Shader
	ALBEDO = basecolor.rgb;
	if (Wireframe) { ALPHA = mix(0.6,0.1, Mask); }
	else { ALPHA = 0.1; }

}