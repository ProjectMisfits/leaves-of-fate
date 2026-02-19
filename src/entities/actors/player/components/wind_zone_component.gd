extends Node2D

@onready var player : Player = $"../.."


func _on_dash_detection_area_body_entered(_body: Node2D) -> void:
	player._current_leaf_dash_mode = player.leaf_dash_mode.DASH_ONLY
	#print("WEEEEEEEEE`")
	pass # Replace with function body.


func _on_no_dash_detection_area_body_entered(_body: Node2D) -> void:
	player._current_leaf_dash_mode = player.leaf_dash_mode.NO_DASH
	#print("NO DASH BABY")
	pass # Replace with function body.

func _on_reset_zone_area_body_entered(_body: Node2D) -> void:
	player._current_leaf_dash_mode = player.leaf_dash_mode.NORMAL
	#print("ResetBaby")
	pass # Replace with function body.
