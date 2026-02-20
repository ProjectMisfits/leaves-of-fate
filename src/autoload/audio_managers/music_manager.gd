extends AudioStreamPlayer
## A manager for playing music during runtime.

## Play the given music stream at the specified volume.
## If the given music is already playing, do nothing.
## If the given music is not already playing, crossfade to the given music.
func _play_song(music: AudioStream, volume: float = 0.0) -> void:
	# If the provided music is already playing, do nothing
	if stream == music:
		return
	
	if not playing:
		# If nothing is playing, start the music directly without a fade.
		stream = music
		play()
	else:
		# Otherwise crossfade to the new music.
		# If something is already playing, fade it out.
		await _fade_out()
		stop()
		stream = music
		volume_db = volume
		play()

## Fade out the currently playing music.
func _fade_out() -> void:
	var fade_out_tween: Tween = create_tween()
	fade_out_tween.tween_property(self, "volume_db", -60.0, 0.5)
	await fade_out_tween.finished
