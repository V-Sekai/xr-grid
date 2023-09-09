extends XRController3D

@onready var sketch_tool = $SketchTool

var prev_hand_transform: Transform3D
var prev_hand_pressed: float
func _process(delta):
	var hand_pressed = get_float("trigger")
	var max_size = 0.01
	
	if is_zero_approx(hand_pressed):
		sketch_tool.active = false
	else:
		sketch_tool.active = true
		sketch_tool.pressure = hand_pressed * max_size
