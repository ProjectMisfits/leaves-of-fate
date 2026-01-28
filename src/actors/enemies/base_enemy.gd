extends CharacterBody2D
class_name Enemey

#state machine to control enemy actions
@onready var state_machine : LimboHSM = $LimboHSM
#enemy max health
@export var max_health : int = 1
#enemy current health
var cur_health : int
#The intial direction of the enemy
var look_direction : float
#Variable keeping track of the players last known position
var player_last_known_pos : Vector2


func _ready() -> void:
	cur_health = max_health
	intialize_statemachine()
	look_direction = $FlipNode.scale.x
	pass
	
#initialize statemachine
func intialize_statemachine()-> void:
	state_machine.initialize(self)
	state_machine.set_active(true)


func _physics_process(delta: float) -> void:
	
	pass

func move_horizontal(direction:float,speed:float,delta: float)->void:

	velocity.x += direction * (speed + delta)
	pass



#Base hurt functionality
func hurt(damage:int)->void:
	cur_health -= damage;
	
#Base death just deletes the object
func death()->void:
	queue_free()
	

func _on_sight_body_entered(body: Node2D) -> void:
	pass # Replace with function body.

#Checks if the player is within visible range and turn to face
func check_player_visible()->bool:
	var player : Array[Node2D] = $FlipNode/Sight.get_overlapping_bodies()
	if player.size() > 0:
		#Player is spoted in idle state chargem
		#If the player is behind the ice cube, flip it then charge
		if(abs(player[0].global_position.x)-abs(global_position.x) < 0) and look_direction == 1:
			flip()
			
			
		elif (abs(player[0].global_position.x)-abs(global_position.x) > 0) and look_direction == -1:
			flip()
			
		player_last_known_pos = player[0].global_position
		
		return true
	return false
	
func flip()->void:
	$FlipNode.scale.x *= -1
	look_direction *= -1
