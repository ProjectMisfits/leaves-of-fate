class_name CameraTrigger extends PlayerEnterTrigger


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

@export var follow_player : bool
@onready var camera : PhantomCamera2D = $PhantomCamera2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	init_trigger()
	EventBus.camera_change.connect(reset_camera_priority)
	_on_trigger = _change_camera


func _change_camera() -> void:
	EventBus.camera_change.emit()
	if(follow_player):
		camera.set_follow_target(player)
	camera.priority = 2
	#CameraManager.create_camera_with_limits($PhantomCamera2D.global_position,1,.5,"LINEAR","EASE_IN",limit_target.get_path())

func reset_camera_priority() -> void:
	camera.priority = 0
	
func _physics_process(_delta: float) -> void:
	##Make sure the phantom camera is not null [TODO] and that your not in a cutscene
	if(camera):
		#Base the camera offset from the input on the left joystick
		#phantom_camera.follow_offset.x = Input.get_axis(&"move_left", &"move_right") * max_offset_x
		camera.follow_offset.x = snappedf(lerpf(camera.follow_offset.x,Input.get_axis(&"move_left", &"move_right") * max_offset_x,offset_speed),rounding_speed)
		camera.follow_offset.y = snappedf( lerpf(camera.follow_offset.y, min_offset_y + (Input.get_axis(&"look_down",&"look_up") * max_offset_y),offset_speed) , rounding_speed)
		 
		#print(phantom_camera.follow_offset.x)
		#print(snappedf(lerpf(camera.follow_offset.x,Input.get_axis(&"move_left", &"move_right") * max_offset_x,offset_speed),rounding_speed))
