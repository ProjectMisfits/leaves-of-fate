extends Node2D
## A manager for the camera, its current target, position, and zoom. Primarily allows for easier cutscene scripting from dialogue resource files.

##The max offset for the x
@export var max_offset_x : float = 1000
##The max offset for the y
@export var max_offset_y : float = -1000
##Minimum offset for the y
@export var min_offset_y : float = -1000
##Speed at which the offset is reached 
@export var offset_speed : float = .05
##Rounding for the offset speed (I.E .01 = round 3.156 to 3.16)
@export var rounding_speed: float = .01

## A reference to the phantom camera used to target objects.
var phantom_camera: PhantomCamera2D
## A reference to the 2D camera.
var camera: Camera2D

func _ready() -> void:
	# If the scene ever gets swapped, delete all existing camera children.
	SceneManager.scene_swap_started.connect(_remove_all_cameras)

## Initialize the camera manager with camera references and signal response functions.
func initialize_camera(player_phantom_camera: PhantomCamera2D, gameplay_camera: Camera2D) -> void:
	phantom_camera = player_phantom_camera
	camera = gameplay_camera
	if not DialogueManager.dialogue_ended.is_connected(_remove_all_cameras.unbind(1)):
		DialogueManager.dialogue_ended.connect(_remove_all_cameras.unbind(1))

## Set the camera's target.
func set_target(target: Node2D) -> void:
	phantom_camera.set_follow_target(target)

func teleport() -> void:
	phantom_camera.teleport_position()

## Clear the camera's target.
func clear_target() -> void:
	phantom_camera.erase_follow_target()

## Create a new phantom camera.
func create_camera(cam_global_position: Vector2, cam_relative_zoom: float, transition_duration: float, transition_type: String, transition_ease: String) -> void:
	# Create the new phantom camera to transition to. Set its priority, position, and zoom.
	var new_cam: PhantomCamera2D = PhantomCamera2D.new()
	new_cam.priority = PhantomCameraManager.get_phantom_camera_2ds().size()
	new_cam.global_position = cam_global_position
	new_cam.zoom = camera.zoom / cam_relative_zoom
	# Create the tween to transition to the new camera. Set its duration, type, and ease.
	var tween: PhantomCameraTween = PhantomCameraTween.new()
	tween.duration = transition_duration
	tween.transition = _string_to_tween_transition_type(transition_type)
	tween.ease = _string_to_tween_ease_type(transition_ease)
	# Assign the tween to the new camera.
	new_cam.tween_resource = tween
	# Add the new camera to the scene tree. The priority being one higher than any other phantom camera means the transition will automatically occur.
	add_child(new_cam)
	await new_cam.tween_completed

## Create a new phantom camera with set limits.
func create_camera_with_limits(cam_global_position: Vector2, cam_relative_zoom: float, transition_duration: float, transition_type: String, transition_ease: String, limit_target: NodePath) -> void:
	# Create the new phantom camera to transition to. Set its priority, position, and zoom.
	var new_cam: PhantomCamera2D = PhantomCamera2D.new()
	new_cam.priority = PhantomCameraManager.get_phantom_camera_2ds().size()
	new_cam.position = cam_global_position
	new_cam.zoom = camera.zoom / cam_relative_zoom
	# Create the tween for transitioning to the new camera. Set its duration, transition type, and easing.
	var tween: PhantomCameraTween = PhantomCameraTween.new()
	tween.duration = transition_duration
	tween.transition = _string_to_tween_transition_type(transition_type)
	tween.ease = _string_to_tween_ease_type(transition_ease)
	# Assign the tween to the new camera.
	new_cam.tween_resource = tween
	# Set the camera's limits.
	new_cam.set_limit_target(limit_target)
	# Add the new camera to the scene tree. The priority being one higher than any other phantom camera means the transition will automatically occur.
	add_child(new_cam)

## Remove all cameras currently managed by this manager.
func _remove_all_cameras() -> void:
	# Don't do anything if there are no cameras.
	if get_child_count() == 0:
		return
	
	# First set the priorities of all of the cameras so that phantom camera tweens back to the player camera.
	for camera_to_remove: PhantomCamera2D in get_children():
		camera_to_remove.set_priority(-1)
	
	# Wait for the tween back to the player to complete.
	if phantom_camera:	# phantom_camera is sometimes null when loading a scene from the Main Menu via. "New Game" or "Continue"
		await phantom_camera.tween_completed
	
	# Now actually delete the cameras.
	for camera_to_remove: PhantomCamera2D in get_children():
		camera_to_remove.queue_free()

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
func set_limit(node_path : NodePath) -> void:
	phantom_camera.set_limit_target(node_path)

##Sets the offset in of the camera 
func set_offset(new_offset : Vector2) -> void:
	phantom_camera.set_follow_offset(new_offset)


func _physics_process(_delta: float) -> void:
	# TODO: Make sure the phantom camera is not null and that the player is not in a cutscene
	if(phantom_camera):
		# Base the camera offset from the input on the left joystick
		phantom_camera.follow_offset.x = snappedf(lerpf(phantom_camera.follow_offset.x,Input.get_axis(&"move_left", &"move_right") * max_offset_x,offset_speed),rounding_speed)
		phantom_camera.follow_offset.y = snappedf( lerpf(phantom_camera.follow_offset.y, min_offset_y + (Input.get_axis(&"look_down",&"look_up") * max_offset_y),offset_speed) , rounding_speed)
