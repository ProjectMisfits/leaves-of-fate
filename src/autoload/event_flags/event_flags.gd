extends Node

## Emitted when a flag is updated.
signal flag_updated(flag_name: String, value: bool)

## String path of the first room to load on a New Game.
const NEW_GAME_ROOM_PATH: String = "res://src/rooms/01_great_hall/01_GreatHall_a_BasicMovement_room.tscn"

var _database: JSON = null
var database_path: String = "res://src/autoload/event_flags/event_flags_db.tres"
var _event_flags: Dictionary[String, bool]

## String path of the first room to load when the Gameplay scene is instantiated.
## This occurs when starting a New Game or Continuing.
var first_room_path: String = "res://src/rooms/01_great_hall/01_GreatHall_a_BasicMovement_room.tscn"

var num_den_conversations : int = 0
var num_great_hall_conversations : int = 0
var num_pantry_conversations : int = 0
var num_cellar_conversations : int = 0

func _enter_tree() -> void:
	# Grab database programmatically
	_database = load(database_path)
	if (_database != null):
		_event_flags.assign(_database.data)
	else:
		push_error("EventFlags: failed to load database from file.")
	
	first_room_path = NEW_GAME_ROOM_PATH	# Set default value for first room path.

## Returns the value of the given flag in the Dictionary.
func get_flag(flag_name: String) -> bool:
	if (not _event_flags.has(flag_name)):	# Error checking
		push_warning("set_flag(): Flag name '%s' could not be found in dictionary." % flag_name)
		return false
	
	return _event_flags.get(flag_name)

## Returns true if flag was successfully set in dictionary or false otherwise.
func set_flag(flag_name: String, value: bool) -> bool:
	if (not _event_flags.has(flag_name)):	# Error checking
		push_warning("set_flag(): Flag name could not be found in dictionary.")
		return false
	
	var is_flag_set: bool = _event_flags.set(flag_name, value)
	if (not is_flag_set):
		push_warning("set_flag(): Failed to set flag value.")
		return false
	
	print("Event Flag Set: ", flag_name, " = ", value)
	
	flag_updated.emit(flag_name, value)
	SaveManager._save_flags()
	return true

## Reset all flags to their default values.
func reset_all_flags() -> void:
	# Clear all existing flags.
	_event_flags.clear()
	# Reload the flag data file.
	_database = load(database_path)
	if _database != null:
		_event_flags.assign(_database.data)

## Set the first room to load when gameplay starts.
func set_first_room(new_first_room_path: String) -> void:
	first_room_path = new_first_room_path
