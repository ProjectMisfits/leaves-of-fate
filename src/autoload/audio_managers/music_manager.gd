extends AudioStreamPlayer
## A manager for playing music during runtime.

## Play the given music stream at the specified volume.
## If the given music is already playing, it will just continue playing.
## If the given music is not already playing, it will stop the currently playing music and play the new one.
func _play_song(music: AudioStream, volume: float = 0.0) -> void:
	print(stream)
	print(music)
	# If the provided music is what's already playing, continue playing
	if stream == music:
		print("Same music")
		if not playing:
			play()
		return

	elif playing:
		print("Crossfade")
		crossfade(music, volume)

	else:
		print("No music --> music")
		#Plays the specified music
		stream = music
		volume_db = volume
		play()


func crossfade(music: AudioStream, volume: float = 0.0) -> void:
	var tween : Tween = create_tween()
	tween.tween_property(self,"volume_db",-60.0,0.5)
	#await tween.finished
	stream = music
	play()
	tween.tween_property(self,"volume_db",volume,0.5)
