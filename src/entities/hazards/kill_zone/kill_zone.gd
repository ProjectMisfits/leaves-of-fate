## Simple Area2D which knocks out the Player when they enter it.
## Scale an instance of this scene to get a box size which suits your needs.
extends Area2D

## How much damage will be dealt to the Player.
## Ideally, the Player would have a function that instantly killed them instead.
var _damage: int = 9999

func _on_body_entered(body: Node2D) -> void:
	if (body is Player):
		body.hurt(_damage)
