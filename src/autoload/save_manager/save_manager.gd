class_name save_manager extends Node

const event_flags_location: String = "user://SaveFile.tres"

const room_location: String = "user://CurrentRoom.tres"

func _save_flags() -> void:
	var file:FileAccess = FileAccess.open(event_flags_location,FileAccess.WRITE)
	if file:
		var json_string : String = JSON.stringify(EventFlags._event_flags)
		file.store_string(json_string)
		file.close()

func _save_room(room : String) -> void:
	var file:FileAccess = FileAccess.open(room_location,FileAccess.WRITE)
	if file:
		file.store_string(room)
		file.close()

func _load_flags() -> void:
	if FileAccess.file_exists(event_flags_location):
		var file:FileAccess = FileAccess.open(event_flags_location,FileAccess.READ)
		var json_text: String = file.get_as_text()
		file.close()
		var parse_result : Dictionary = JSON.parse_string(json_text)
		if parse_result is Dictionary:
			EventFlags._event_flags.assign(parse_result)

func _load_room() -> String:
	if FileAccess.file_exists(room_location):
		var file:FileAccess = FileAccess.open(room_location,FileAccess.READ)
		var room: String = file.get_as_text()
		file.close()
		return room
	else:
		return "res://src/ui/intro_letter/intro_letter.tscn"


func _check_save() -> bool:
	if FileAccess.file_exists(event_flags_location):
		var file:FileAccess = FileAccess.open(event_flags_location,FileAccess.READ)
		var json_text: String = file.get_as_text()
		file.close()
		return JSON.parse_string(json_text) is Dictionary && FileAccess.file_exists(room_location)

	else:
		return false
