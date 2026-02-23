extends Node2D

@onready var player : Player = $"../.."


func _on_dash_detection_area_body_entered(_body: Node2D) -> void:
	player.infinite_dash = true
	#print("WEEEEEEEEE`")

func _on_no_dash_detection_area_body_entered(_body: Node2D) -> void:
	player.no_dash = true
	#print("NO DASH BABY")

func _on_dash_detection_area_body_exited(_body: Node2D) -> void:
	player.infinite_dash = false

func _on_no_dash_detection_area_body_exited(_body: Node2D) -> void:
	player.no_dash = false
	#print("EXited no dash zone")
