extends AudioStreamPlayer
## A manager for playing ambiance during runtime.

## The currently playing ambiance.
var current_ambiance: Ambiance

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

#Plays ambiance and one off sounds in the game's background
func _play_ambiance(new_ambiance: Ambiance, new_volume: float = 0.0) -> void:
	# If the provided ambiance is already playing, do nothing.
	if current_ambiance == new_ambiance:
		return
	
	# If something is already playing, fade it out. If nothing is playing, the new ambiance will just start directly.
	if playing:
		await _fade_out()
		stop()
	
	# Start the new ambiance.
	current_ambiance = new_ambiance
	stream = new_ambiance.background
	volume_db = new_volume
	play()
	_play_one_off()

## Play one off ambiance sounds randomly while ambiance is playing.
func _play_one_off() -> void:
	# TODO: Find a way to make playing one off ambiance sound effects not
	# dependent on a while loop. The await means that the ambiance could change
	# during the await, call this method, and then fail because "if not playing"
	# never gets caught. I want to make sure that this method updates correctly.
	while playing:
		# Wait a random amount of time between one off sounds
		await get_tree().create_timer(randf_range(5,25)).timeout
		# If the ambiance background is no longer playing, stop playing one offs
		if not playing:
			return
		# Create a temporary AudioStreamPlayer to play a random one off sound
		var player : AudioStreamPlayer = AudioStreamPlayer.new()
		player.name = "OneOffSoundPlayer"
		player.stream = current_ambiance.one_offs.pick_random()
		# Add the player to the scene and play its sound
		add_child(player)
		player.play()
		# Once the sound is done, remove the temporary AudioStreamPlayer
		await player.finished
		player.queue_free()

## Fade out the currently playing ambiance.
func _fade_out() -> void:
	var fade_out_tween: Tween = create_tween()
	fade_out_tween.tween_property(self, "volume_db", -60.0, 0.5)
	await fade_out_tween.finished
