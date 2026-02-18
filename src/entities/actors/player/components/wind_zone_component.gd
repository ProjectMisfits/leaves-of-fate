extends Node2D

@onready var player : Player = $"../.."

func _on_dash_detection_area_body_entered(body: Node2D) -> void:
	player._current_leaf_dash_mode = player.leaf_dash_mode.DASH_ONLY
	print("WEEEEEEEEE`")
	pass # Replace with function body.


func _on_no_dash_detection_area_body_entered(body: Node2D) -> void:
	player._current_leaf_dash_mode = player.leaf_dash_mode.NO_DASH
	print("NO DASH BABY")
	pass # Replace with function body.


func _on_dash_detection_area_body_exited(body: Node2D) -> void:
	player._current_leaf_dash_mode = player.leaf_dash_mode.NORMAL
	print("EXITING NORMAL FROM DASH")
	pass # Replace with function body.


func _on_no_dash_detection_area_body_exited(body: Node2D) -> void:
	player._current_leaf_dash_mode = player.leaf_dash_mode.NORMAL
	print("EXITING NORMAL FROM NO DASH")
	pass # Replace with function body.
	
	
