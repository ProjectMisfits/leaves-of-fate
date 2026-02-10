extends AudioStreamPlayer
## A manager for playing ambiance during runtime.

var current_ambiance: Ambiance

#Plays ambiance and one off sounds in the game's background
func _load_ambiance(ambiance: Ambiance) -> void:
	#If ambiance is already loaded, return
	if ambiance == current_ambiance:
		if not playing:
			_play()
		return
	
	#Loads the new ambiance
	current_ambiance = ambiance
	
	#Plays ambiance's background
	stream = ambiance.background
	play()
	_play_one_off()

#Plays one off sounds randomly when ambiance is playing
func _play_one_off()->void:
	#Randomly play sound effects when aumbiance is playing
	while (playing):
		#Wait a random amount of time in between one off sounds
		await get_tree().create_timer(randf_range(5,25)).timeout
		if(!playing):
			return
		#Create a new Audio Player and set it to play a random one off sound
		var player : AudioStreamPlayer = AudioStreamPlayer.new()
		player.name = "OneOffSoundPlayer"
		player.stream = current_ambiance.one_offs.pick_random()
		#Add the player to the scene and play its sound
		add_child(player)

		player.play()
		#After the sound is played, remove its player
		await player.finished
		player.queue_free()

#Plays ambiance and random one off sounds
func _play(from_position: float = 0.0) -> void:
	_play_one_off()
	play(from_position)
	
