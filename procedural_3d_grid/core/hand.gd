# Copyright (c) 2018-present. This file is part of V-Sekai https://v-sekai.org/.
# SaracenOne & K. S. Ernest (Fire) Lee & Lyuma & MMMaellon & Contributors
# hand.gd
# SPDX-License-Identifier: MIT

extends XRController3D

@onready var sketch_tool = $SketchTool

var prev_hand_transform: Transform3D
var prev_hand_pressed: float


func _process(delta) -> void:
	var hand_pressed = get_float("trigger")
	var max_size = 0.01

	if is_zero_approx(hand_pressed):
		sketch_tool.active = false
	else:
		sketch_tool.active = true
		sketch_tool.pressure = hand_pressed * max_size
