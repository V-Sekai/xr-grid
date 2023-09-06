extends Node3D

@export var hand_left:XRController3D
@export var hand_right:XRController3D

var prev_hand_left_transform:Transform3D
var prev_hand_right_transform:Transform3D
var prev_hand_left_pressed:bool
var prev_hand_right_pressed:bool
func _process(delta):
	var hand_left_pressed = hand_left.get_float("grip_force") > 0.05
	var hand_right_pressed = hand_right.get_float("grip_force") > 0.05
	
	if prev_hand_left_pressed && prev_hand_right_pressed:
		transform = pinchTransform(
			transform, 
			prev_hand_left_transform.origin, prev_hand_right_transform.origin,
			hand_left.transform.origin, hand_right.transform.origin)
	elif prev_hand_left_pressed:
		transform = hand_left.transform * prev_hand_left_transform.affine_inverse() * transform
	elif prev_hand_right_pressed:
		transform = hand_right.transform * prev_hand_right_transform.affine_inverse() * transform
	
	prev_hand_left_transform = hand_left.transform
	prev_hand_right_transform = hand_right.transform
	prev_hand_left_pressed = hand_left_pressed
	prev_hand_right_pressed = hand_right_pressed

func pinchTransform(_transform:Transform3D, from_a:Vector3, from_b:Vector3, to_a:Vector3, to_b:Vector3) -> Transform3D:
	from_b -= from_a
	to_b -= to_a
	
	_transform = _transform.translated(-from_a).scaled(Vector3(1,1,1) * sqrt( to_b.dot(to_b) / from_b.dot(from_b) ) )

	var axis = from_b.cross(to_b)
	var angle = from_b.angle_to(to_b)
	if axis: _transform = _transform.rotated(axis.normalized(), angle)
	
	_transform = _transform.translated(to_a)
	
	return _transform
