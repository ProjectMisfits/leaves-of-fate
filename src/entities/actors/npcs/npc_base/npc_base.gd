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
	# Start out by playing their idle animation
	animation_player.play(idle_animation)
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
func move(destination_global_x: float, move_speed: float, animate_walk: bool = true, moonwalk: bool = false) -> void:
	# Determine which direction the NPC needs to move
	move_axis = -1.0 if destination_global_x < global_position.x else 1.0
	# Set the direction to face based on the direction to move and moonwalk
	if not moonwalk:
		set_look(move_axis)
	else:
		set_look(move_axis * -1.0)
	
	# Set NPC velocity
	target_x = destination_global_x
	velocity = Vector2(move_speed * move_axis, 0)
	# Set NPC move animation
	if animate_walk:
		animation_player.play(walk_animation)

## Set the NPC to look in the given direction.
## look_direction: "left" or "right"
func set_look(face_axis: float) -> void:
	flip_node.scale.x = face_axis
