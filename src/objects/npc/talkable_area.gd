extends Area2D

#Dialogue that this character is currently has
@export var dialogue_resource: DialogueResource
#Where the dialogue will start when you interact
@export var dialouge_start: String = "start"

func talk() -> void:
	DialogueManager.show_example_dialogue_balloon(dialogue_resource,dialouge_start)
