extends NPC


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	match SceneManager.current_scene.name:
		"TEST_DialogueManager":
		
			dialogue_resource = ResourceLoader.load("res://assets/dialogue/dialogue_scripts/1-Az-Meet-GreatHall.dialogue")
			dialogue_start = "start"
		"GB_GreatHall":
			dialogue_resource = ResourceLoader.load("res://assets/dialogue/dialogue_scripts/1-Az-Meet-GreatHall.dialogue")
			dialogue_start = "start"
		_:
			dialogue_resource = ResourceLoader.load("res://assets/dialogue/dialogue_scripts/TUTORIAL-RichTextLabel.dialogue")
			dialogue_start = "start"
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
