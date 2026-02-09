extends Node2D
class_name Spawner

##Json containing spawner info
@export var database : JSON = null

##Object that will be spawned 
@export var object : PackedScene

##Flag check for whether or not it spawns continuously or in bursts 
##Continous spawns only based on the time between objects while burst use the addition burst time variable
var burst : bool

##Boolean for if the spawner should spawn things as soon as it's ready or not 
var immediate_spawn : bool

##If the spawner spawns in bursts 
var burst_time : float

##If the spawner is burst how many of the object should be in each burst
var burst_num : int

##Time in between spawning objects
var time_between_objects : float 

##Current number of objects alive
var cur_objects : int = 0

##Current number of objects in burst created 
var cur_burst : int = 0

##Timer for the spawn time
@onready var spawn_timer : Timer = $SpawnTimer

##Timer for burst time
@onready var burst_timer : Timer = $BurstTimer


func _enter_tree() -> void:
	if (database != null):
		var db_data: Dictionary = database.data
		initialize_data(db_data)
	else:
		push_error("Database is equal to 'null'.")
		
func initialize_data(data: Dictionary) -> void:
	burst = data["burst"]
	burst_time = data["burst_time"]
	time_between_objects = data["time_between_objects"]
	immediate_spawn = data["immediate_spawn"]
	burst_num = data["burst_num"]


func _ready() -> void:
	#Check if you should spawn things immediatly or wait for a timer
	if(immediate_spawn):
		spawn()
	else:
		if(burst):
			burst_timer.start(burst_time)
		else:
			spawn_timer.start(time_between_objects)


##Function which handles spawning for continous spawners
func spawn() -> void:
	#Instance a new version of the packed scene
	var instance : Node2D = object.instantiate()
	add_child(instance)
	
	#Check if it's a burst spawner
	if(burst):
		#If it is a burst spawner check if you have spawned all items in the burst
		if(cur_burst == burst_num):
			#If you have then start the burst timer and reset cur_burst to 0
			cur_burst = 0; 
			burst_timer.start(burst_time)
		else:
			##If you haven't then just start the spawner timer and incriment the number of burst items
			cur_burst += 1
			spawn_timer.start(time_between_objects)
	else:
		#If it is not a burst timer then just start the start timer again
		spawn_timer.start(time_between_objects)


func _on_spawn_timer_timeout() -> void:
	spawn()
	pass # Replace with function body.


func _on_burst_timer_timeout() -> void:
	spawn()
	pass # Replace with function body.
