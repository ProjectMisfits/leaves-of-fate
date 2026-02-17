extends Node

var _database: JSON = null
var database_path: String = "res://src/autoload/event_flags/event_flags_db.tres"
var _event_flags: Dictionary[String, bool]

# EVENT FLAG-RELATED VARIABLES #
var num_heaters_activated: int = 0	## Updates when a heater_activated flag is set
var winston_name: String = "Wizard"	##  Updated by Dialogue resources during specific conversations

func _enter_tree() -> void:
	# Grab database programatically
	_database = load(database_path)
	if (_database != null):
		_event_flags.assign(_database.data)
	else:
		push_error("EventFlags: failed to load database from file.")

func _ready() -> void:
	update_num_heaters_activated()

## Returns the value of the given flag in the Dictionary.
func get_flag(flag_name: String) -> bool:
	if (not _event_flags.has(flag_name)):	# Error checking
		push_warning("set_flag(): Flag name could not be found in dictionary.")
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
	
	# Check if heater number needs to be updated
	if ("heater" in flag_name):
		update_num_heaters_activated()
	
	return true

## Updates num_heaters_activated; increases by 1 for each heater_activated flag set to true.
func update_num_heaters_activated() -> void:
	var new_num_heaters_activated: int = 0
	
	if (_event_flags.get("heater_1_activated")):
		new_num_heaters_activated += 1
	if (_event_flags.get("heater_2_activated")):
		new_num_heaters_activated += 1
	if (_event_flags.get("heater_3_activated")):
		new_num_heaters_activated += 1
	
	num_heaters_activated = new_num_heaters_activated
