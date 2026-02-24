extends AudioStreamPlayer
## A manager for playing music during runtime.

## Play the given music stream at the specified volume.
## If the given music is already playing, do nothing.
## If the given music is not already playing, crossfade to the given music.
func _play_song(new_music: AudioStream, new_volume: float = 0.0) -> void:
	# If the provided music is already playing, do nothing.
	if stream == new_music:
		return
	
	# If something is already playing, fade it out. If nothing is playing, the new music will just start directly.
	if playing:
		await _fade_out()
		stop()
	
	# Start the new music.
	stream = new_music
	volume_db = new_volume
	play()

## Fade out the currently playing music.
func _fade_out() -> void:
	var fade_out_tween: Tween = create_tween()
	fade_out_tween.tween_property(self, "volume_db", -60.0, 0.5)
	await fade_out_tween.finished
