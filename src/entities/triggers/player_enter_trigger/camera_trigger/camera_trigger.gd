class_name CameraTrigger extends PlayerEnterTrigger



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_on_trigger = _change_camera


func _change_camera() -> void:
	print("Setting new offsets")
	#$PhantomCamera2D.priority_override = true
	print($PhantomCamera2D.limit_target)
	CameraManager.create_camera_with_limit($PhantomCamera2D,.5,"LINEAR","EASE_IN")
