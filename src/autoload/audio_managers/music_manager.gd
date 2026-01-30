extends AudioStreamPlayer

#Plays music in the game's background at the specified volume
func _play_song(music: AudioStream, volume: float = 0.0)->void:
	#If music is already playing, return
	if stream == music:
		return
	
	#Plays the specified music
	stream = music
	volume_db = volume
	play()
