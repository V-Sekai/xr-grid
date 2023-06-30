shader_type spatial;

render_mode unshaded;
//render_mode cull_disabled;
//render_mode world_vertex_coords;
render_mode skip_vertex_transform;

uniform uint _DisplayGridLines;

//uniform mat4 _CanvasToWorldMatrix;
uniform vec3 _GridAnchorPos;
uniform float _DistanceBetweenPoints;
uniform float _PointRadius = .02;
uniform uint _PointsPerDim;

uniform vec4 _Color : source_color = vec4(0,0,0,1);

uniform float _NearFade = .5;
uniform float _FarFade = .5;
uniform float _FadeZone = .5;
uniform vec3 _FocusPoint = vec3(0,0,0);


vec3 xform(mat4 m, vec3 p, const int w){return (m * vec4(p,float(w))).xyz;}

// Calculates line billboard in view space
mat4 getLineBillboard(vec3 a,vec3 b){
    mat4 billboard = mat4(1);
    billboard[0].xyz = (b-a)/2.;
    billboard[1].xyz = normalize( cross(b,a) );
    billboard[2].xyz = normalize( cross(billboard[0].xyz, billboard[1].xyz) );
    billboard[3].xyz = (b+a)/2.;
    return billboard;
}

float computeOpacity(mat4 worldToView, vec3 viewSpacePos, float baseOpacity)
{
    // Compare world space input position with focus point world space position
    float focus_point_distance = distance(viewSpacePos, xform(worldToView, _FocusPoint, 1));
    float opacity = baseOpacity;
    if (focus_point_distance > _FarFade)
    {
        opacity = clamp(1.0 + (_FarFade - focus_point_distance) / _FadeZone, 0.0, 1.0) * baseOpacity;
    }

    float depth = viewSpacePos.z * -1.0;
    if (depth < _NearFade)
    {
        opacity = clamp(-_FadeZone + depth / _NearFade, 0.0, 1.0) * baseOpacity;
    }

    return opacity;
}

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
	pos = xform(worldToView,pos,1);
	
	normal = mat3(modelToView) * normal;
	
	modelToView = getLineBillboard(pos, pos+normal*2.0);
	modelToView[1].xyz *= lineWidth;
	/*
	modelToView[0].xyz = normal;
	modelToView[1].xyz = normalize( vec3(-normal.y, normal.x, 0) )*lineWidth;
	modelToView[2].xyz = vec3(0,0,1);
	modelToView[3].xyz = xform(worldToView,pos,1);*/
}

void vertex(){
	COLOR = _Color;
	
	mat4 eye_matrix = VIEW_MATRIX;
	eye_matrix[3].xyz -= EYE_OFFSET;
	
	mat4 inv_eye_matrx = INV_VIEW_MATRIX;
	inv_eye_matrx[3].xyz += EYE_OFFSET;
	
	MODELVIEW_MATRIX[3].xyz -= EYE_OFFSET;
	
	if(UV.x < 0.5){
		handlePoint(MODEL_MATRIX, eye_matrix, inv_eye_matrx, MODELVIEW_MATRIX);
	}
	else{
		handleLine(NORMAL, MODEL_MATRIX, eye_matrix, inv_eye_matrx, MODELVIEW_MATRIX);
		COLOR.a *= .4;
	}
	
	MODELVIEW_MATRIX[3].xyz += EYE_OFFSET;
	
	VERTEX = xform(MODELVIEW_MATRIX,VERTEX,1);
	
	COLOR.a = computeOpacity(VIEW_MATRIX, VERTEX, COLOR.a);
}

void fragment(){
	ALBEDO = COLOR.rgb;
	ALPHA = COLOR.a;
}