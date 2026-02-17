extends Node
class_name HurtComponent
##A reference to the players collision box shape
@onready var player_collision : CollisionShape2D = $"../../CollisionShape2D"

##A reference to the hurt areas collision box shape
@onready var hurt_box : CollisionShape2D = $HurtArea/CollisionShape2D

##Reference to player
@onready var player : Player = $"../.."


func _ready() -> void:
	hurt_box.shape = player_collision.shape

func _on_hurt_area_body_entered(body: Node2D) -> void:
	player.hurt(1)
