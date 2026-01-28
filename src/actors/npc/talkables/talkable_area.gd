extends Area2D

#Dialogue that this character is currently has
@export var dialogue_resource: DialogueResource
#Where the dialogue will start when you interact
@export var dialogue_start: String = "start"
#What balloon are they using 
@export var balloon: PackedScene = null

func talk() -> void:
	print("Attempting speech")
	DialogueManager.show_dialogue_balloon_scene(balloon,dialogue_resource,dialogue_start)

	
