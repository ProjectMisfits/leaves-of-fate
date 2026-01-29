extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$CanvasLayer/Letter/Control.modulate.a = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	_progress_to_gameplay()


func _on_timer_timeout() -> void:
	create_tween().tween_property($CanvasLayer/Letter/Control, "modulate:a", 1.0, 0.5)

func _progress_to_gameplay() -> void:
	if $CanvasLayer/Letter/Control.modulate.a == 1.0 && Input.is_action_just_pressed(&"ui_accept"):
		SceneManager.swap_scenes("res://src/gameplay/gameplay.tscn", null, self)
