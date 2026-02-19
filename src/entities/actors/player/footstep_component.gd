extends Node2D
class_name FootstepComponent

##Tracks where to look for tiles to make sounds
@export var marker : Marker2D

##The component that will play your audio
@export var audio_component : AudioStreamPlayer2D

##Dictionary of sounds and audio 
@export var sound_dictionary :  JSON

var cur_tile_data : String

func _physics_process(_aadelta: float) -> void:
	get_tile_data()


func get_tile_data() -> void:
	var tilemap : TileMapLayer = get_tree().get_first_node_in_group("midground")
	
	if not tilemap:
		return 
	
	var cell : Vector2i = tilemap.local_to_map(marker.global_position)
	var data : TileData = tilemap.get_cell_tile_data(cell)
	var tile_data : String
	if data:
		tile_data = data.get_custom_data("FootstepSound")
	
	if tile_data and (not tile_data == cur_tile_data):
		print("CHANGED")
		var dictionary : Dictionary = sound_dictionary.data
		audio_component.stream = dictionary[tile_data]
		cur_tile_data = tile_data
		
