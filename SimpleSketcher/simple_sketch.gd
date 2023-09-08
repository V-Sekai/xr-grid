@tool
class_name SimpleSketch extends RefCounted

var target_mesh:ArrayMesh

var is_beginning = false
func stroke_begin():
	is_beginning = true

var prev_point
var prev_size
var prev_color
func stroke_add(point:Vector3, size:float=.01, color:Color=Color(0,0,0)):
	
	if is_beginning:
		addLine(point, point, size, size, color, color, true)
		is_beginning = false
	else:
		addLine(prev_point, point, prev_size, size, prev_color, color)
	
	prev_point = point
	prev_size = size
	prev_color = color

func stroke_end():
	pass

var prev_tangent:Vector3
func addLine(from:Vector3, to:Vector3, from_size:float=.01, to_size:float=.01, from_color:Color=Color(0,0,0), to_color:Color=Color(0,0,0), begin_stroke:bool = false):
	assert(target_mesh != null)
	
	var from_tangent = prev_tangent
	var to_tangent = to - from
	
	if begin_stroke:
		from_tangent = to_tangent
	
	
	# Begin draw.
	var arrays = []
	arrays.resize(ArrayMesh.ARRAY_MAX)
	arrays[ArrayMesh.ARRAY_VERTEX] = PackedVector3Array()
	arrays[ArrayMesh.ARRAY_TANGENT] = PackedFloat32Array()
	arrays[ArrayMesh.ARRAY_TEX_UV] = PackedVector2Array()
	arrays[ArrayMesh.ARRAY_COLOR] = PackedColorArray()
	
	# Build on original mesh if possible
	if target_mesh.get_surface_count() > 0:
		arrays = target_mesh.surface_get_arrays(0) #target_mesh.get_surface_count()-1)
	
	arrays[ArrayMesh.ARRAY_VERTEX].append(from)
	arrays[ArrayMesh.ARRAY_TANGENT] += PackedFloat32Array([from_tangent.x, from_tangent.y, from_tangent.z, 1.0])
	arrays[ArrayMesh.ARRAY_TEX_UV].append(Vector2(0, -from_size))
	arrays[ArrayMesh.ARRAY_COLOR].append(from_color)
	
	arrays[ArrayMesh.ARRAY_VERTEX].append(from)
	arrays[ArrayMesh.ARRAY_TANGENT] += PackedFloat32Array([from_tangent.x, from_tangent.y, from_tangent.z, 1.0])
	arrays[ArrayMesh.ARRAY_TEX_UV].append(Vector2(0, from_size))
	arrays[ArrayMesh.ARRAY_COLOR].append(from_color)
	
	arrays[ArrayMesh.ARRAY_VERTEX].append(to)
	arrays[ArrayMesh.ARRAY_TANGENT] += PackedFloat32Array([to_tangent.x, to_tangent.y, to_tangent.z, 1.0])
	arrays[ArrayMesh.ARRAY_TEX_UV].append(Vector2(0, -to_size))
	arrays[ArrayMesh.ARRAY_COLOR].append(to_color)
	
	arrays[ArrayMesh.ARRAY_VERTEX].append(to)
	arrays[ArrayMesh.ARRAY_TANGENT] += PackedFloat32Array([to_tangent.x, to_tangent.y, to_tangent.z, 1.0])
	arrays[ArrayMesh.ARRAY_TEX_UV].append(Vector2(0, to_size))
	arrays[ArrayMesh.ARRAY_COLOR].append(to_color)
	
	target_mesh.clear_surfaces()
	target_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLE_STRIP, arrays)
	
#	target_mesh.surface_begin(Mesh.PRIMITIVE_TRIANGLE_STRIP)
#
#	target_mesh.surface_set_normal(from_tangent)
#	target_mesh.surface_set_uv(Vector2(0, -from_size))
#	target_mesh.surface_set_color(from_color)
#	target_mesh.surface_add_vertex(from)
#
#	target_mesh.surface_set_normal(from_tangent)
#	target_mesh.surface_set_uv(Vector2(0, from_size))
#	target_mesh.surface_set_color(from_color)
#	target_mesh.surface_add_vertex(from)
#
#	target_mesh.surface_set_normal(to_tangent)
#	target_mesh.surface_set_uv(Vector2(0, -to_size))
#	target_mesh.surface_set_color(to_color)
#	target_mesh.surface_add_vertex(to)
#
#	target_mesh.surface_set_normal(to_tangent)
#	target_mesh.surface_set_uv(Vector2(0, to_size))
#	target_mesh.surface_set_color(to_color)
#	target_mesh.surface_add_vertex(to)
#
#	# End drawing.
#	target_mesh.surface_end()
	
	prev_tangent = to_tangent
