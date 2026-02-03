class_name NPC extends Node2D

"""
HOW TO USE/SET UP NPC DIALOGUE:
	So you want to make a new npc and want to make it so that it picks its own dialogue in each room.
	I reccomend using this switch statement below as a template.
	Essentially each npc will have their own switch statements in their ready functions
	which determines the dialogue resource and start line for each one.
	Note that room names do not include the _room at the end so just add the first half
"""

## The dialogue sequence that this cutscene trigger will initiate.
@export var dialogue_resource: DialogueResource

## The line to start at in the dialogue sequence.
@export var dialogue_start: String = "start"

## The dialogue balloon that this cutscene trigger should use.
var dialogue_balloon: PackedScene = preload("res://src/ui/dialogue_boxes/dialogue_box.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	match SceneManager.current_scene.name:
		"TEST_DialogueManager":
			dialogue_resource = ResourceLoader.load("res://assets/dialogue/dialogue_scripts/1-Az-Meet-GreatHall.dialogue")
			dialogue_start = "start"
		_:
			dialogue_resource = ResourceLoader.load("res://assets/dialogue/dialogue_scripts/TUTORIAL-RichTextLabel.dialogue")
			dialogue_start = "start"

func _on_interactable_interact_triggered() -> void:
	DialogueManager.show_dialogue_balloon_scene(dialogue_balloon, dialogue_resource, dialogue_start)
