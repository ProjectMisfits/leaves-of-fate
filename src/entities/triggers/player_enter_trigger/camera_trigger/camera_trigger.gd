class_name CameraTrigger extends PlayerEnterTrigger

@export var limit_target : TileMapLayer



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	EventBus.camera_change.connect(reset_camera_priority)
	print(limit_target.get_path())
	_on_trigger = _change_camera


func _change_camera() -> void:
	print("Setting new offsets")
	EventBus.camera_change.emit()
	$PhantomCamera2D.priority = 2
	#CameraManager.create_camera_with_limits($PhantomCamera2D.global_position,1,.5,"LINEAR","EASE_IN",limit_target.get_path())

func reset_camera_priority() -> void:
	$PhantomCamera2D.priority = 0
