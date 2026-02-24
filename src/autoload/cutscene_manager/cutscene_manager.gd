extends Node
## A manager for cutscene sequences. Allows npc movement to be scripted from dialogue resource files.

## A signal emitted whenever a cutscene starts.
signal cutscene_started

## A signal emitted whenever a cutscene ends.
signal cutscene_ended

## A signal emitted when an NPC finishes moving.
signal npc_finished_moving

## An array containing all npcs in the current room that are available for movement scripting during a cutscene.
var npcs: Array[NPC]

func _ready() -> void:
	# If the scene ever gets swapped, reset cutscenes
	SceneManager.scene_swap_started.connect(_on_cutscene_ended)
	# When a cutscene ends, reset cutscenes
	cutscene_ended.connect(_on_cutscene_ended)

## Takes an npc name and returns an instance of the npc associated with that name.
func _npc_name_to_instance(npc_name: String) -> NPC:
	match npc_name:
		"Az":
			return preload("res://src/entities/actors/npcs/npc_az/npc_az.tscn").instantiate()
		"Winston":
			return preload("res://src/entities/actors/npcs/npc_winston/npc_winston.tscn").instantiate()
		_:
			return null

## Get the NPC with the given name from the npcs array. If the given NPC doesn't exist, returns null.
func _get_npc(npc_name: String) -> NPC:
	for npc: NPC in npcs:
		if npc.npc_name == npc_name:
			return npc
	return null

## Adds the given NPC to the NPCs array.
func register_npc(npc: NPC) -> void:
	# Make sure the NPC doesn't already exist
	if _get_npc(npc.npc_name) != null:
		push_error("CutsceneManager: Duplicate NPC %s registered!" % npc.npc_name)
		return
	npcs.append(npc)

## Create the specified npc at the given location.
func create_npc(npc_name: String, position: Vector2) -> void:
	# Create the NPC
	var npc_instance: NPC = _npc_name_to_instance(npc_name)
	# Check that the NPC was created successfully
	if npc_instance == null:
		push_error("CutsceneManager: No valid NPC for name %s." % npc_name)
		return
	# Add the NPC to the list of NPCs in the cutscene and set its position
	npcs.append(npc_instance)
	npc_instance.global_position = position

## Remove the specified npc from the cutscene.
func remove_npc(npc_name: String) -> void:
	# Get a reference to the NPC
	var npc_instance: NPC = _get_npc(npc_name)
	# If the NPC was in the list of NPCs, remove it from the list and delete it.
	if npc_instance == null:
		push_error("CutsceneManager: No valid NPC for name %s." % npc_name)
		return
	npcs.erase(npc_instance)
	npc_instance.queue_free()

## Move the specified npc in the given direction for the given duration or distance.
func npc_move(npc_name: String, destination_global_x: float = 1.0, move_speed: float = 1.0, animate_walk: bool = true, moonwalk: bool = false) -> void:
	# Get a reference to the NPC
	var npc_instance: NPC = _get_npc(npc_name)
	if npc_instance == null:
		push_error("CutsceneManager: No valid NPC for name %s." % npc_name)
		return
	# Script the NPC to move to a position.
	npc_instance.move(destination_global_x, move_speed, animate_walk, moonwalk)
	await npc_finished_moving

## Turn the specified npc to face the given direction.
func npc_face(npc_name: String, direction: String) -> void:
	# Get a reference to the NPC
	var npc_instance: NPC = _get_npc(npc_name)
	if npc_instance == null:
		push_error("CutsceneManager: No valid NPC for name %s." % npc_name)
		return
	# Script the NPC to face a direction.
	if direction == "left":
		npc_instance.set_look(-1.0)
	elif direction == "right":
		npc_instance.set_look(1.0)
	else:
		push_error("CutsceneManager: Invalid NPC look direction given.")

## End cutscene management.
func _on_cutscene_ended() -> void:
	# Clear all registered npcs.
	npcs.clear()

## Fade the screen to black for use in cutscenes.
func fade_to_black() -> void:
	await SceneManager.add_screen_transition("fade")

## Fade the screen from black for use in cutscenes.
func fade_from_black() -> void:
	await SceneManager.remove_screen_transition()

## Change the music to the given file during a cutscene.
## The given argument must be the full path ("res://assets/...") to the desired music file.
func change_music(music_file_path: String) -> void:
	MusicManager._play_song(load(music_file_path))

## Play the given sound effect during a cutscene.
func play_sound(sound_file_path: String) -> void:
	# Create a temporary AudioStreamPlayer to play the sound effect
	var sound_player: AudioStreamPlayer = AudioStreamPlayer.new()
	sound_player.name = "CutsceneSoundEffectPlayer"
	sound_player.stream = load(sound_file_path)
	# Add the player to the scene and play its sound
	add_child(sound_player)
	sound_player.play()
	# Once the sound is done, remove the temporary AudioStreamPlayer
	await sound_player.finished
	sound_player.queue_free()

## Wait for a given number of seconds before continuing a cutscene.
func wait(seconds: float) -> void:
	await get_tree().create_timer(seconds).timeout
