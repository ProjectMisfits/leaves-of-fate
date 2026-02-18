class_name CreditsMenu extends Control

@export var scroll_speed: int = 1
@export var scroll_box: ScrollContainer
@export var was_closed: bool = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	scroll_box =  %ScrollContainer


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if was_closed:
		await get_tree().create_timer(0.65).timeout
		was_closed = false 
	
	if Engine.get_process_frames() % 2 == 0:
		if scroll_box != null && !(scroll_box.scroll_vertical >= scroll_box.get_v_scroll_bar().max_value):
			scroll_box.scroll_vertical += scroll_speed
