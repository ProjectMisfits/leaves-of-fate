extends AudioStreamPlayer
## A manager for playing music during runtime.

## Play the given music stream at the specified volume.
## If the given music is already playing, it will just continue playing.
## If the given music is not already playing, it will stop the currently playing music and play the new one.
func _play_song(music: AudioStream, volume: float = 0.0) -> void:
	# If the provided music is what's already playing, continue playing
	if stream == music:
		if not playing:
			play()
		return
	
	#Plays the specified music
	stream = music
	volume_db = volume
	play()
