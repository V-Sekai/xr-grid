@tool
class_name SketchTool extends Node3D

@export var CANVAS: NodePath
@onready var canvas: Node3D = get_node(CANVAS)

@export var active: bool = false
@export var pressure: float = 0.0
@export var color: Color = Color.BLACK

@onready var simple_sketch = SimpleSketch.new()
func _ready():
	assert(canvas != null)
	
	simple_sketch.target_mesh = canvas.get_child(0).mesh

var prev_active = false
func _process(delta):
	if active and not prev_active:
		simple_sketch.stroke_begin()
	
	if active and prev_active:
		var point = canvas.to_local(global_transform.origin)
		simple_sketch.stroke_add(point, pressure / canvas.scale.x, color)
	
	if not active and prev_active:
		simple_sketch.stroke_end()
	
	prev_active = active