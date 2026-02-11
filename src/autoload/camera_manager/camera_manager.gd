extends Node2D
## A manager for the camera, its current target, position, and zoom. Primarily allows for easier cutscene scripting from dialogue resource files.

## A reference to the phantom camera used to target objects.
var phantom_camera: PhantomCamera2D
## A reference to the 2D camera.
var camera: Camera2D

## Initialize the camera manager with camera references and signal response functions.
func initialize_camera(player_phantom_camera: PhantomCamera2D, gameplay_camera: Camera2D) -> void:
	phantom_camera = player_phantom_camera
	camera = gameplay_camera
	DialogueManager.dialogue_ended.connect(_restore_camera)

## Set the camera's target.
func set_target(target: Node2D) -> void:
	phantom_camera.set_follow_target(target)

func teleport() -> void:
	phantom_camera.teleport_position()

## Clear the camera's target.
func clear_target() -> void:
	phantom_camera.erase_follow_target()

## Create a new phantom camera.
## Relative position will move it relative to wherever the current phantom camera is.
## The current camera is either the one focused on the player or the most recent camera added by this function.
func create_camera(relative_position: Vector2, relative_zoom: float, transition_duration: float, transition_type: String, transition_ease: String) -> void:
	# Create the new phantom camera to transition to. Set its priority, position, and zoom.
	var new_camera: PhantomCamera2D = PhantomCamera2D.new()
	new_camera.priority = PhantomCameraManager.get_phantom_camera_2ds().size()
	if self.get_child_count() == 0:
		new_camera.position = camera.position + relative_position
	else:
		new_camera.position = get_child(-1).position + relative_position
	new_camera.zoom = camera.zoom / relative_zoom
	# Create the tween for transitioning to the new camera. Set its duration, transition type, and easing.
	var tween: PhantomCameraTween = PhantomCameraTween.new()
	tween.duration = transition_duration
	tween.transition = _string_to_tween_transition_type(transition_type)
	tween.ease = _string_to_tween_ease_type(transition_ease)
	
	# Assign the tween to the new camera.
	new_camera.tween_resource = tween
	
	# Add the new camera to the scene tree. The priority being one higher than any other phantom camera means the transition will automatically occur.
	add_child(new_camera)

## Change the priorities of all cameras to tween back to the original camera.
func _restore_camera(_resource: DialogueResource) -> void:
	for camera_to_remove: PhantomCamera2D in self.get_children():
		remove_child(camera_to_remove)

## Get the phantom camera tween transition type for the given string.
func _string_to_tween_transition_type(type: String) -> PhantomCameraTween.TransitionType:
	match type:
		"LINEAR":
			return PhantomCameraTween.TransitionType.LINEAR
		"QUINT":
			return PhantomCameraTween.TransitionType.QUINT
		"QUART":
			return PhantomCameraTween.TransitionType.QUART
		"QUAD":
			return PhantomCameraTween.TransitionType.QUAD
		"EXPO":
			return PhantomCameraTween.TransitionType.EXPO
		"ELASTIC":
			return PhantomCameraTween.TransitionType.ELASTIC
		"CUBIC":
			return PhantomCameraTween.TransitionType.CUBIC
		"CIRC":
			return PhantomCameraTween.TransitionType.CIRC
		"BOUNCE":
			return PhantomCameraTween.TransitionType.BOUNCE
		"BACK":
			return PhantomCameraTween.TransitionType.BACK
		"SINE", _:
			return PhantomCameraTween.TransitionType.SINE

## Get the phantom camera tween ease type for the given string.
func _string_to_tween_ease_type(type: String) -> PhantomCameraTween.EaseType:
	match type:
		"EASE_IN":
			return PhantomCameraTween.EaseType.EASE_IN
		"EASE_OUT":
			return PhantomCameraTween.EaseType.EASE_OUT
		"EASE_OUT_IN":
			return PhantomCameraTween.EaseType.EASE_OUT_IN
		"EASE_IN_OUT", _:
			return PhantomCameraTween.EaseType.EASE_IN_OUT

## Set the camera's limit target to a specifc tilemap layer
func set_limit(node_path: NodePath) -> void:
	phantom_camera.set_limit_target(node_path)
