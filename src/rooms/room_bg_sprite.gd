@tool
class_name RoomBackgroundSprite2D extends Sprite2D

## Used by [Room] to set the background texture via [RoomThemeConfig].

func _init() -> void:
	if not Engine.is_editor_hint():
		return;
	if not self.texture:
		self.texture = preload("res://assets/rooms/backgrounds/bg_missing.tres");
	self.centered = false;
	self.scale.x = 128.0;
	self.scale.y = 1.0;
