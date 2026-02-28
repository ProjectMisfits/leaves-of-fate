class_name MusicTrigger extends PlayerEnterTrigger
## A trigger for playing music tracks. Will stop any currently playing tracks and replace them with the set one.

## The music track to play.
@export var music_track: AudioStream

## The volume to play the music track at, in decibels.
@export var music_volume: float = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	init_trigger()
	_on_trigger = _play_music

## Play the given music.
func _play_music() -> void:
	MusicManager._play_song(music_track, music_volume)
