extends Node2D

@onready var player : Player = $"../.."


func _on_dash_detection_area_body_entered(_body: Node2D) -> void:
	player.infinite_dash = true

func _on_no_dash_detection_area_body_entered(_body: Node2D) -> void:
	player.no_dash = true

func _on_dash_detection_area_body_exited(_body: Node2D) -> void:
	player.infinite_dash = false

func _on_no_dash_detection_area_body_exited(_body: Node2D) -> void:
	player.no_dash = false
