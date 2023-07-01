class_name SimpleSketch extends RefCounted

var target_mesh:ImmediateMesh

# TODO: fix surfaces

func _init():
	pass

var prev_tangent:Vector3
func addLine(from:Vector3, to:Vector3, from_size:float=.01, to_size:float=.01, from_color:Color=Color(0,0,0), to_color:Color=Color(0,0,0), begin_stroke:bool = false):
	assert(target_mesh != null)
	
	var from_tangent = prev_tangent
	var to_tangent = to - from
	
	if begin_stroke:
		from_tangent = to_tangent
	
	# Begin draw.
	target_mesh.surface_begin(Mesh.PRIMITIVE_TRIANGLE_STRIP)
	
	target_mesh.surface_set_normal(from_tangent)
	target_mesh.surface_set_uv(Vector2(0, -from_size))
	target_mesh.surface_set_color(from_color)
	target_mesh.surface_add_vertex(from)
	
	target_mesh.surface_set_normal(from_tangent)
	target_mesh.surface_set_uv(Vector2(0, from_size))
	target_mesh.surface_set_color(from_color)
	target_mesh.surface_add_vertex(from)
	
	target_mesh.surface_set_normal(to_tangent)
	target_mesh.surface_set_uv(Vector2(0, -to_size))
	target_mesh.surface_set_color(to_color)
	target_mesh.surface_add_vertex(to)
	
	target_mesh.surface_set_normal(to_tangent)
	target_mesh.surface_set_uv(Vector2(0, to_size))
	target_mesh.surface_set_color(to_color)
	target_mesh.surface_add_vertex(to)
	
	# End drawing.
	target_mesh.surface_end()
	
	prev_tangent = to_tangent
