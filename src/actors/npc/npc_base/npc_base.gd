extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	print(SceneManager.current_scene.name)
	match SceneManager.current_scene.name:
		"TEST_DialogueManager":
			print("we")
			$TalkableArea.dialogue_resource = ResourceLoader.load("res://assets/dialogue/dialogue_scripts/1-Az-Meet-GreatHall.dialogue")
			$TalkableArea.dialogue_start = "start"
		_:
			$TalkableArea.dialogue_resource = ResourceLoader.load("res://assets/dialogue/dialogue_scripts/TUTORIAL-RichTextLabel.dialogue")
			$TalkableArea.dialogue_start = "start"
	
	pass # Replace with function body.
