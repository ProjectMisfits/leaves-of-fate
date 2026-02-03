class_name NPC extends Node2D

"""
HOW TO USE/SET UP NPC DIALOGUE:
	So you want to make a new npc and want to make it so that it picks its own dialogue in each room.
	I reccomend using this switch statement below as a template.
	Essentially each npc will have their own switch statements in their ready functions
	which determines the dialogue resource and start line for each one.
	Note that room names do not include the _room at the end so just add the first half
"""

@export var dialogue_resource: DialogueResource
#Where the dialogue will start when you interact
@export var dialogue_start: String = "start"
#What balloon are they using 
@export var balloon: PackedScene = null

var dialogue_triggered: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:

	match SceneManager.current_scene.name:
		"TEST_DialogueManager":
			dialogue_resource = ResourceLoader.load("res://assets/dialogue/dialogue_scripts/1-Az-Meet-GreatHall.dialogue")
			dialogue_start = "start"
		_:
			dialogue_resource = ResourceLoader.load("res://assets/dialogue/dialogue_scripts/TUTORIAL-RichTextLabel.dialogue")
			dialogue_start = "start"
	
	pass # Replace with function body.


func _on_interactable_interact_triggered() -> void:
	if (dialogue_triggered):
		return
	
	print("Attempting speech")
	DialogueManager.show_dialogue_balloon_scene(balloon,dialogue_resource,dialogue_start)
	dialogue_triggered = true
