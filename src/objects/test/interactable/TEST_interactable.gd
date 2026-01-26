extends CharacterBody2D

@onready var sprite2d: Sprite2D = $Sprite2D

func highlight() -> void:
	sprite2d.modulate = Color.YELLOW

func unhighlight() -> void:
	sprite2d.modulate = Color.WHITE

# Triggered by Interactable.interact_triggered()
func interact() -> void:
	print("WAOW! YOU INTERACTED WITH ME! YIPPEE!")
