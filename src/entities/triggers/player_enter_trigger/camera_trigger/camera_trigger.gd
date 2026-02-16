class_name CameraTrigger extends PlayerEnterTrigger

@export var limit_target : TileMapLayer
@export var follow_player : bool
@export var change_offset : Vector2
@onready var camera : PhantomCamera2D = $PhantomCamera2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	EventBus.camera_change.connect(reset_camera_priority)
	print(limit_target.get_path())
	_on_trigger = _change_camera


func _change_camera() -> void:
	EventBus.camera_change.emit()
	if(follow_player):
		camera.set_follow_target(player)
	camera.priority = 2
	#CameraManager.create_camera_with_limits($PhantomCamera2D.global_position,1,.5,"LINEAR","EASE_IN",limit_target.get_path())

func reset_camera_priority() -> void:
	camera.priority = 0
	
