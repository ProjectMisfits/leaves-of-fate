class_name NPC extends CharacterBody2D
## A character body whose movement can be scripted during cutscenes.

## The name of this NPC.
@export var npc_name: String = ""

## A reference to this NPC's AnimationPlayer.
@onready var animation_player: AnimationPlayer = $AnimationPlayer

## The name of this NPC's walk cycle animation.
@export var walk_animation: String = ""

## The name of this NPC's idle animation.
@export var idle_animation: String = ""

## A reference to the node that controls the scale of the NPC. Used to change NPC look direction.
@onready var flip_node: Node2D = $FlipNode

## The axis of the current movement. 0 if not moving.
var move_axis: float = 0

## The time remaining on movement duration.
var target_x: float = global_position.x

func _ready() -> void:
	# Register this NPC with the cutscene manager.
	CutsceneManager.register_npc(self)

func _physics_process(delta: float) -> void:
	# Check whether we're at our target x. If so, stop moving.
	if global_position.x != target_x:
		# If the NPC is at or beyond its target x relative to the direction it's moving,
		# reset its velocity and just place it at its target location.
		if (global_position.x - target_x) * move_axis > 0:
			velocity = Vector2.ZERO
			move_axis = 0
			global_position.x = target_x
			animation_player.play(idle_animation)
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	move_and_slide()

## Move the NPC based on the given parameters.
## move_direction: one of "left" or "right"
func move(move_direction: String, distance: float = 1.0, speed: float = 1.0, animate_walk: bool = true, moonwalk: bool = false) -> void:
	# Set the direction to face
	if not moonwalk:
		set_look(move_direction)
	else:
		if move_direction == "left":
			set_look("right")
		elif move_direction == "right":
			set_look("left")
		else:
			push_error("NPC: Invalid look direction given.")
			return
	
	# Set NPC velocity
	move_axis = -1 if move_direction == "left" else 1
	target_x = global_position.x + distance * move_axis
	velocity = Vector2(speed * move_axis, 0)
	# Set NPC move animation
	if animate_walk:
		animation_player.play(walk_animation)

## Set the NPC to look in the given direction.
## look_direction: "left" or "right"
func set_look(look_direction: String) -> void:
	if look_direction == "left":
		flip_node.scale.x = -1.0
	elif look_direction == "right":
		flip_node.scale.x = 1.0
	else:
		push_error("NPC %s: Invalid look direction given." % npc_name)
