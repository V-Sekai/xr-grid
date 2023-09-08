shader_type spatial;

render_mode unshaded;
render_mode skip_vertex_transform;
render_mode cull_disabled;
render_mode depth_draw_always;

mat4 getLineBillboard(vec3 a,vec3 b){
    mat4 billboard = mat4(1);
    billboard[0].xyz = (b-a)/2.;
    billboard[1].xyz = normalize( cross(b,a) );
    billboard[2].xyz = normalize( cross(billboard[0].xyz, billboard[1].xyz) );
    billboard[3].xyz = (b+a)/2.;
    return billboard;
}

void vertex(){
	VERTEX = ( MODEL_MATRIX * vec4(VERTEX,1) ).xyz;
	vec3 tangent = mat3(MODELVIEW_MATRIX) * TANGENT;
	
	float m = .4;
	VERTEX.x += VERTEX.y * m;
	tangent.x += tangent.y * m;
	
	UV *= length(MODEL_MATRIX[0].xyz);
	VERTEX += UV.x * tangent + UV.y * normalize(vec3(-tangent.y, 0, tangent.z));

	VERTEX.y = 0.001;
}
void fragment(){
	ALBEDO = vec3(0.02);
	ALPHA = COLOR.a;
}