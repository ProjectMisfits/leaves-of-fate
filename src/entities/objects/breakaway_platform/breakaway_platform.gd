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

##Should the platform fall
@export var stationary : bool 

##Gravity scale
@export var gravity : float


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
	respawnable = data["respawnable"]
	stationary = data["stationary"]
	gravity = data["gravity"]

#Player has entered, only the player can interact with this platform so there is no need to check 
func _on_area_2d_body_entered(_body: Node2D) -> void:
	sprite.texture = ResourceLoader.load("res://assets/entities/objects/breakaway_platform/Breakable-platform-brittle.png")
	break_timer.start(break_time)

func _ready() -> void:
	constant_linear_velocity = Vector2(0,gravity)
	sprite.texture = ResourceLoader.load("res://assets/entities/objects/breakaway_platform/BreakablePlatform-01.png") 


func _physics_process(_delta: float) -> void:
	#apply gravity at all times
	if(not stationary):
		move_and_collide(constant_linear_velocity)

#Once the break timer has gone disable collisions
func _on_break_time_timeout() -> void:
	sprite.hide()
	$IceShardParticles.emitting = true
	physical_collider.set_deferred("disabled",true)
	break_away_collider.set_deferred("disabled",true)
	#If the platform can respawn start the respawn timer
	if(respawnable):
		respawn_timer.start(respawn_time)
	else:
		queue_free()

func _on_respawn_time_timeout() -> void:
	if(not player_present):
		sprite.modulate = Color(1.0, 1.0, 1.0, 1.0)
		sprite.show()
		sprite.texture = ResourceLoader.load("res://assets/entities/objects/breakaway_platform/BreakablePlatform-01.png") 
		physical_collider.set_deferred("disabled",false)
		break_away_collider.set_deferred("disabled",false)
	else:
		respawn_timer.start(.1)
		


func _on_player_check_body_entered(_body: Node2D) -> void:
	player_present = true


func _on_player_check_body_exited(_body: Node2D) -> void:
	player_present = false
	
