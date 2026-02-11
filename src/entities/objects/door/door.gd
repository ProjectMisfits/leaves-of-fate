class_name Door extends Area2D
## A door that the player can interact with to move to a new room.

## Triggered when the player interacts with this Door.
signal player_entered_door(door: Door)

## The path of the Room to load when the player enters this Door.
@export_file("*_room.tscn") var path_to_target_room: String

## The name of this Door.
@export var door_name: String

## The name of the Door to spawn at in the target Room.
@export var target_door_name: String

## Whether the player is on top of this door. Used to allow/disallow interacting with this door.
var player_on_door: bool = false

## Emit the player_entered_door signal when the door is entered.
func _physics_process(_delta: float) -> void:
	# Make sure that the player is currently overlapping the door and they pressed the interact button
	if player_on_door and Input.is_action_just_pressed("interact"):
		player_entered_door.emit(self)

## Triggered when a body begins overlapping the door.
func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group('player'):
		player_on_door = true

## Triggered when a body stops overlapping the door.
func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group('player'):
		player_on_door = false
