extends StaticBody2D

#Timers for breaking away and respawning
@onready var break_timer : Timer = $BreakTime
@onready var respawn_timer : Timer = $RespawnTime
var break_time : float
var respawn_time : float

#Sprites and collision
@onready var sprite : Sprite2D = $Sprite2D
@onready var physical_collider : CollisionShape2D = $CollisionShape2D
@onready var break_away_collider : CollisionShape2D = $BreakAwayArea/CollisionShape2D

@export var database : JSON = null

##Decides whether or not the platform will return after a certain amount of time
@export var respawnable : bool 

##variable to keep track if the player is in the area
var player_present : bool 

func _enter_tree() -> void:
	if (database != null):
		var db_data: Dictionary = database.data
		initialize_data(db_data)
	else:
		push_error("Database is equal to 'null'.")

func initialize_data(data: Dictionary) -> void:
	break_time = data["break_time"]
	respawn_time = data["respawn_time"]

#Player has entered, only the player can interact with this platform so there is no need to check 
func _on_area_2d_body_entered(_body: Node2D) -> void:
	sprite.modulate = Color(1.0, 0.426, 0.357, 1.0)
	break_timer.start(break_time)


#Once the break timer has gone disable collisions
func _on_break_time_timeout() -> void:
	sprite.hide()
	physical_collider.set_deferred("disabled",true)
	break_away_collider.set_deferred("disabled",true)
	#If the platform can respawn start the respawn timer
	if(respawnable):
		respawn_timer.start(respawn_time)


func _on_respawn_time_timeout() -> void:
	if(not player_present):
		sprite.modulate = Color(1.0, 1.0, 1.0, 1.0)
		sprite.show()
		physical_collider.set_deferred("disabled",false)
		break_away_collider.set_deferred("disabled",false)
	else:
		respawn_timer.start(.1)
		


func _on_player_check_body_entered(_body: Node2D) -> void:
	player_present = true


func _on_player_check_body_exited(_body: Node2D) -> void:
	player_present = false
	
