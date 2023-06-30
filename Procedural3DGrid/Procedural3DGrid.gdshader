shader_type spatial;

render_mode unshaded;
render_mode cull_disabled;
//render_mode world_vertex_coords;
//render_mode skip_vertex_transform;

uniform uint _DisplayGridLines;

uniform mat4 _CanvasToWorldMatrix;
uniform vec3 _GridAnchorPos;
uniform float _DistanceBetweenPoints;
uniform float _PointRadius = 1.0;
uniform uint _PointsPerDim;

uniform vec4 _Color : source_color = vec4(0,0,0,1);

uniform float _NearFade;
uniform float _FarFade;
uniform float _FadeZone;
uniform vec3 _FocusPoint;
uniform float _BaseOpacity;


vec3 xform(mat4 m, vec3 p, const int w){return (m * vec4(p,float(w))).xyz;}


void handlePoint(mat4 modelToWorld, mat4 worldToView, mat4 viewToWorld, inout mat4 modelToView){
	vec3 pos = modelToWorld[3].xyz;// + floor(viewToWorld[3].xyz);
	
	modelToView[0].xyz = vec3(_PointRadius,0,0);
	modelToView[1].xyz = vec3(0,_PointRadius,0);
	modelToView[2].xyz = vec3(0,0,_PointRadius);
	modelToView[3].xyz = xform(worldToView,pos,1);
}

void handleLine(vec3 normal, mat4 modelToWorld, mat4 worldToView, mat4 viewToWorld, inout mat4 modelToView){
	float lineWidth = _PointRadius * 0.3;
	
	vec3 pos = modelToWorld[3].xyz;// + floor(viewToWorld[3].xyz);
	
	normal = mat3(modelToView) * normal;
	
	modelToView[0].xyz = normal;
	modelToView[1].xyz = normalize( vec3(-normal.y, normal.x, 0) )*lineWidth;
	modelToView[2].xyz = vec3(0,0,1);
	modelToView[3].xyz = xform(worldToView,pos,1);
}

void vertex(){
	COLOR = _Color;
	
	if(UV.x < 0.5){
		handlePoint(MODEL_MATRIX, VIEW_MATRIX, INV_VIEW_MATRIX, MODELVIEW_MATRIX);
	}
	else{
		handleLine(NORMAL, MODEL_MATRIX, VIEW_MATRIX, INV_VIEW_MATRIX, MODELVIEW_MATRIX);
		COLOR.a *= .4;
	}
	//MODELVIEW_MATRIX[3].xyz = vec3(0,0,1);
	
}

void fragment(){
	ALBEDO = COLOR.rgb;
	ALPHA = COLOR.a;
	ALPHA *= 1.0 - smoothstep(0.5, 1.0, length(VERTEX)/8.0);
	ALPHA *= smoothstep(0.0,.5,-VERTEX.z);
}