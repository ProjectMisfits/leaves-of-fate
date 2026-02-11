extends CharacterBody2D
class_name Enemy

#state machine to control enemy actions
@onready var state_machine : LimboHSM = $LimboHSM
#Node to keep track of items that need to be fliped
@onready var flip_node : Node2D = $FlipNode

#enemy max health
var max_health : int
#enemy current health
var cur_health : int
#The intial direction of the enemy
var look_direction : float
#Variable keeping track of the players last known position
var player_last_known_pos : Vector2


func _ready() -> void:
	intialize_statemachine()
	look_direction = flip_node.scale.x

#initialize statemachine
func intialize_statemachine() -> void:
	state_machine.initialize(self)
	state_machine.set_active(true)

func _physics_process(_delta: float) -> void:
	move_and_slide()

#code for horizontal movement for enemies that includes acceleration and deceleration
func move_horizontal(direction:float, acceleration:float, deceleration: float, delta: float, turn_speed:float, max_speed:float) -> void:
	var new_velocity: float = 0.0
	var new_acceleration: float = 0.0
	#print(direction)
	
	if (direction == 0.0): # No direction 
		new_velocity = move_toward(velocity.x, 0, deceleration)
	elif (signf(direction) == signf(velocity.x)): 	# Direction matches current velocity
		new_acceleration = direction * acceleration * delta
	else: 											# Direction is opposite to current velocity
		new_acceleration = direction * turn_speed *delta
	
	new_velocity = clampf(velocity.x + new_acceleration, -max_speed, max_speed)
	
	velocity.x = new_velocity

#Base hurt functionality
func hurt(damage:int) -> void:
	cur_health -= damage;

#Base death just deletes the object
func death() -> void:
	queue_free()

#Checks if the player is within visible range and turn to face
func check_player_visible() -> bool:
	var player : Array[Node2D] = $FlipNode/Sight.get_overlapping_bodies()
	if player.size() > 0:
		
		#If the player is behind the enemy, flip it then charge
		var player_abs_x : float= abs(player[0].global_position.x)
		var enemy_abs_x :float = abs(global_position.x)
		
		if(player_abs_x-enemy_abs_x < 0) and look_direction == 1:
			flip()
			
			
		elif (player_abs_x-enemy_abs_x >0) and look_direction == -1:
			flip()
			
		player_last_known_pos = player[0].global_position
		
		return true
	return false

func flip() -> void:
	flip_node.scale.x *= -1
	look_direction *= -1
