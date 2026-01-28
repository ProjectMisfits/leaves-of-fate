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


func _ready() -> void:
	cur_health = max_health
	intialize_statemachine()
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
	
func flip()->void:
	$FlipNode.scale.x *= -1
	look_direction *= -1
