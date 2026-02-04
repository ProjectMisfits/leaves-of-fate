extends StaticBody2D

#Timers for breaking away and respawning
@onready var break_timer : Timer = $BreakTime
@onready var respawn_timer : Timer = $RespawnTime

#Sprites and collision
@onready var sprite : Sprite2D = $Sprite2D
@onready var physical_collider : CollisionShape2D = $CollisionShape2D
@onready var break_away_collider : CollisionShape2D = $Area2D/CollisionShape2D

#Decides whether or not the platform will return after a certain amount of time
@export var respawnable : bool 

#Player has entered, only the player can interact with this platform so there is no need to check 
func _on_area_2d_body_entered(_body: Node2D) -> void:
	sprite.modulate = Color(1.0, 0.426, 0.357, 1.0)
	break_timer.start()


#Once the break timer has gone disable collisions
func _on_break_time_timeout() -> void:
	sprite.hide()
	physical_collider.set_deferred("disabled",true)
	physical_collider.set_deferred("disabled",true)
	#If the platform can respawn start the respawn timer
	if(respawnable):
		respawn_timer.start()


func _on_respawn_time_timeout() -> void:
	sprite.modulate = Color(1.0, 1.0, 1.0, 1.0)
	sprite.show()
	physical_collider.set_deferred("disabled",false)
	physical_collider.set_deferred("disabled",false)
