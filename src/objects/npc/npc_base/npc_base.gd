extends Node2D

@onready var dialogue_resource : DialogueResource = $TalkableArea.dialogue_resource
@onready var dialogue_start : String = $TalkableArea.dialouge_start

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	print(SceneManager.current_scene.name)
	match SceneManager.current_scene.name:
		"TEST_DialogueManager":
			dialogue_resource = ResourceLoader.load("res://assets/dialogue/dialogue_scripts/1-Az-Meet-GreatHall.dialogue")
			dialogue_start = "start"
		_:
			dialogue_resource = ResourceLoader.load("res://assets/dialogue/dialogue_scripts/TUTORIAL-RichTextLabel.dialogue")
			dialogue_start = "start"
	
	pass # Replace with function body.
