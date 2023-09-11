# Copyright (c) 2018-present. This file is part of V-Sekai https://v-sekai.org/.
# SaracenOne & K. S. Ernest (Fire) Lee & Lyuma & MMMaellon & Contributors
# xr_pinch.gd
# SPDX-License-Identifier: MIT

extends Node3D

@export var hand_left: XRController3D = null
@export var hand_right: XRController3D = null

var prev_hand_left_transform: Transform3D
var prev_hand_right_transform: Transform3D
var prev_hand_left_pressed: float = 0
var prev_hand_right_pressed: float = 0

var _world_grab = WorldGrab.new()

var target_transform: Transform3D = transform
func _process(_delta: float) -> void:
	var hand_left_pressed: float = hand_left.get_float("grip")
	var hand_right_pressed: float = hand_right.get_float("grip")

	var from_pivot : Vector3
	var to_pivot : Vector3

	var delta_transform: Transform3D
	if prev_hand_left_pressed && prev_hand_right_pressed:
		from_pivot = prev_hand_left_transform.origin + prev_hand_right_transform.origin
		to_pivot = hand_left.transform.origin + hand_right.transform.origin
		
		delta_transform = _world_grab.get_pinch_transform(prev_hand_left_transform.origin, prev_hand_right_transform.origin, hand_left.transform.origin, hand_right.transform.origin)
	elif prev_hand_left_pressed:
		from_pivot = prev_hand_left_transform.origin
		to_pivot = hand_left.transform.origin
		
		delta_transform = _world_grab.get_grab_transform(prev_hand_left_transform, hand_left.transform)
	elif prev_hand_right_pressed:
		from_pivot = prev_hand_right_transform.origin
		to_pivot = hand_right.transform.origin
		
		delta_transform = _world_grab.get_grab_transform(prev_hand_right_transform, hand_right.transform)
	else:
		from_pivot = Vector3()
		to_pivot = Vector3()
		delta_transform = Transform3D()

	target_transform = delta_transform * target_transform
	
	#transform = _world_grab.split_blend(transform, target_transform, .2, 1.0, 1.0, from_pivot, to_pivot)
	transform = target_transform
	
	
	prev_hand_left_transform = hand_left.transform
	prev_hand_right_transform = hand_right.transform
	prev_hand_left_pressed = hand_left_pressed
	prev_hand_right_pressed = hand_right_pressed


func pinch_transform(_transform: Transform3D, from_a: Vector3, from_b: Vector3, to_a: Vector3, to_b: Vector3) -> Transform3D:
	from_b -= from_a
	to_b -= to_a

	_transform = _transform.translated(-from_a).scaled(Vector3(1, 1, 1) * sqrt(to_b.dot(to_b) / from_b.dot(from_b)))

	var axis: Vector3 = from_b.cross(to_b)
	var angle: float = from_b.angle_to(to_b)
	if axis:
		_transform = _transform.rotated(axis.normalized(), angle)

	_transform = _transform.translated(to_a)

	return _transform
