# Copyright (c) 2018-present. This file is part of V-Sekai https://v-sekai.org/.
# SaracenOne & K. S. Ernest (Fire) Lee & Lyuma & MMMaellon & Contributors
# procedural_grid_3d.gd
# SPDX-License-Identifier: MIT

@tool
extends Node3D

@export var level_color:GradientTexture1D
@export var distance_between_points := 0.5

# Should be optional
@export_node_path("Node3D") var FOCUS_NODE: NodePath
#@onready var focus_node = get_node(FOCUS_NODE)
#@export_node_path("Node3D") var focus_node : Node3D = null

@onready var grid1 = $BaseProceduralGrid3D
@onready var grid2 = $BaseProceduralGrid3D/BaseProceduralGrid3D2

func _process(delta):
	var exponent = log(global_transform.basis[0].length())/log(2.0)
	var level = floor( exponent )
	grid1.scale = Vector3(distance_between_points,distance_between_points,distance_between_points) / pow(2.0, level)

	if level_color:
		var color:Color = level_color.gradient.sample(level*.5 + 0.5)
		color.a *= clamp(2.0 - (exponent - floor(exponent))*2.0, 0.0, 1.0)
		grid1.material_override.set_shader_parameter("_Color", color)
		color = level_color.gradient.sample((level+1)*.5 + 0.5)
		color.a *= clamp((exponent - floor(exponent))*2.0, 0.0, 1.0)
		grid2.material_override.set_shader_parameter("_Color", color)
		
	if FOCUS_NODE:
		grid1.material_override.set_shader_parameter("_FocusPoint", get_node(FOCUS_NODE).global_position)
		grid2.material_override.set_shader_parameter("_FocusPoint", get_node(FOCUS_NODE).global_position)
