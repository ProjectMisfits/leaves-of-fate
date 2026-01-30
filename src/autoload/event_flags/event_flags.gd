extends Node

var _database: JSON = null
var database_path: String = "res://src/autoload/event_flags/event_flags_db.tres"
var _event_flags: Dictionary[String, bool]

### EVENT FLAG-RELATED VARIABLES ###
var num_heaters_actived: int = 0	# Updates when a heater_activated flag is set
var winston_name: String = ""	#  Updated by Dialogue resources when specific conversations are triggered

func _enter_tree() -> void:
	# Grab database programatically
	_database = load(database_path)
	if (_database != null):
		_event_flags.assign(_database.data)
	else:
		push_error("EventFlags: failed to load database from file.")

func _ready() -> void:
	update_num_heaters_activated()
	update_winston_name()

# Returns the value of the given flag in the Dictionary.
func get_flag(flag_name: String) -> bool:
	if (not _event_flags.has(flag_name)):	# Error checking
		push_warning("set_flag(): Flag name could not be found in dictionary.")
		return false
	
	return _event_flags.get(flag_name)

# Returns true if flag was successfully set in dictionary or false otherwise.
func set_flag(flag_name: String, value: bool) -> bool:
	if (not _event_flags.has(flag_name)):	# Error checking
		push_warning("set_flag(): Flag name could not be found in dictionary.")
		return false
	
	var is_flag_set: bool = _event_flags.set(flag_name, value)
	if (not is_flag_set):
		push_warning("set_flag(): Failed to set flag value.")
		return false
	
	print("Event Flag Set: ", flag_name, " = ", value)
	
	update_num_heaters_activated()
	update_winston_name()
	
	return true

# Updates num_heaters_activated; increases by 1 for each heater_activated flag set to true.
func update_num_heaters_activated() -> void:
	var new_num_heaters_activated: int = 0
	
	if (_event_flags.get("heater_one_activated")):
		new_num_heaters_activated += 1
	if (_event_flags.get("heater_two_activated")):
		new_num_heaters_activated += 1
	if (_event_flags.get("heater_three_activated")):
		new_num_heaters_activated += 1
	
	num_heaters_actived = new_num_heaters_activated
	#print("Number of Heaters Activated: ", num_heaters_actived)

# Updates winston_name; changes depending on which conversation flags have been triggered.
func update_winston_name() -> void:
	var new_winston_name: String = ""
	
	# TODO: Replace the conditional below with the proper event flags
	if (_event_flags.get("ws_meet_cellar_general_triggered")):
		new_winston_name = "Winston"
	else:
		new_winston_name = "bro"
	
	winston_name = new_winston_name
