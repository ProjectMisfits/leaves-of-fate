class_name AmbianceTrigger extends PlayerEnterTrigger
## A trigger for playing ambiance sounds. Will stop any currently playing sounds and replace them with the set one.

## The ambiance to play.
@export var ambiance_resource: Ambiance

## The volume to play the ambiance at, in decibels.
@export var ambiance_volume: float = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_on_trigger = _play_ambiance

## Play the given ambiance.
func _play_ambiance() -> void:
	AmbianceManager._play_ambiance(ambiance_resource, ambiance_volume)
