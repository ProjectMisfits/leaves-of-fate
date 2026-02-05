extends Node
@onready var press_audio: AudioStreamPlayer = $Press
@onready var hover_audio: AudioStreamPlayer = $Hover





func _on_controls_button_mouse_entered() -> void:
	if(hover_audio.playing):
		hover_audio.play()

func _on_controls_button_pressed() -> void:
	if(press_audio.playing):
		press_audio.play()

func _on_volume_button_pressed() -> void:
	if(press_audio.playing):
		press_audio.play()

func _on_volume_button_mouse_entered() -> void:
	if(hover_audio.playing):
		hover_audio.play()

func _on_back_button_pressed() -> void:
	if(press_audio.playing):
		press_audio.play()

func _on_back_button_mouse_entered() -> void:
	if(hover_audio.playing):
		hover_audio.play()
