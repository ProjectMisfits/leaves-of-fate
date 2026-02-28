class_name CameraResetTrigger extends PlayerEnterTrigger



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	init_trigger()
	_on_trigger = _reset_camera


func _reset_camera() -> void:
	#CameraManager._restore_camera(null)
	EventBus.camera_change.emit()
	
