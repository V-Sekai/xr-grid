# Copyright (c) 2018-present. This file is part of V-Sekai https://v-sekai.org/.
# SaracenOne & K. S. Ernest (Fire) Lee & Lyuma & MMMaellon & Contributors
# xr_origin.gd
# SPDX-License-Identifier: MIT

extends Node3D

var interface: XRInterface = null
var vr_supported = false


func _ready():
	# Find our interface and check if it was successfully initialised.
	# Note that Godot should initialise this automatically IF you've
	# enabled it in project settings!
	interface = XRServer.find_interface("OpenXR")
	if interface and interface.is_initialized():
		print("OpenXR initialised successfully")

		var vp: Viewport = get_viewport()
		vp.use_xr = true
		print(vp.size)
		return

	# We assume this node has a button as a child.
	# This button is for the user to consent to entering immersive VR mode.
	$CanvasLayer/Button.pressed.connect(self._on_button_pressed)

	interface = XRServer.find_interface("WebXR")
	if interface:
		# WebXR uses a lot of asynchronous callbacks, so we connect to various
		# signals in order to receive them.
		interface.session_supported.connect(self._webxr_session_supported)
		interface.session_started.connect(self._webxr_session_started)
		interface.session_ended.connect(self._webxr_session_ended)
		interface.session_failed.connect(self._webxr_session_failed)

		# This returns immediately - our _webxr_session_supported() method
		# (which we connected to the "session_supported" signal above) will
		# be called sometime later to let us know if it's supported or not.
		interface.is_session_supported("immersive-vr")


func _webxr_session_supported(session_mode, supported):
	if session_mode == "immersive-vr":
		vr_supported = supported


func _on_button_pressed():
	if not vr_supported:
		OS.alert("Your browser doesn't support VR")
		return

	# We want an immersive VR session, as opposed to AR ('immersive-ar') or a
	# simple 3DoF viewer ('viewer').
	interface.session_mode = "immersive-vr"
	# 'bounded-floor' is room scale, 'local-floor' is a standing or sitting
	# experience (it puts you 1.6m above the ground if you have 3DoF headset),
	# whereas as 'local' puts you down at the XROrigin.
	# This list means it'll first try to request 'bounded-floor', then
	# fallback on 'local-floor' and ultimately 'local', if nothing else is
	# supported.
	interface.requested_reference_space_types = "bounded-floor, local-floor, local"
	# In order to use 'local-floor' or 'bounded-floor' we must also
	# mark the features as required or optional.
	interface.required_features = "local-floor"
	interface.optional_features = "bounded-floor"

	# This will return false if we're unable to even request the session,
	# however, it can still fail asynchronously later in the process, so we
	# only know if it's really succeeded or failed when our
	# _webxr_session_started() or _webxr_session_failed() methods are called.
	if not interface.initialize():
		OS.alert("Failed to initialize")
		return


func _webxr_session_started():
	$CanvasLayer/Button.visible = false
	# This tells Godot to start rendering to the headset.
	get_viewport().use_xr = true
	# This will be the reference space type you ultimately got, out of the
	# types that you requested above. This is useful if you want the game to
	# work a little differently in 'bounded-floor' versus 'local-floor'.
	print("Reference space type: " + interface.reference_space_type)


func _webxr_session_ended():
	$CanvasLayer/Button.visible = true
	# If the user exits immersive mode, then we tell Godot to render to the web
	# page again.
	get_viewport().use_xr = false


func _webxr_session_failed(message):
	OS.alert("Failed to initialize: " + message)
