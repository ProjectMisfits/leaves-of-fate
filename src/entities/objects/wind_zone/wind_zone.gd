## Wind Zones give or take away the Player's wind while the Player remains in the zone.
extends Area2D

enum wind_zone_mode {GAIN, DRAIN}	## Mode for Wind Zones.

@export var database: JSON = null	## JSON Resource containing numerical data.
@export var mode: wind_zone_mode = wind_zone_mode.GAIN	## Determines whether the Wind Zone will give or take away the Player's wind.

var _wind_gain_rate: float		## Amount of wind given to the Player per second.
var _wind_drain_rate: float		## Amount of wind taken from the Player per second.
var _gain_zone_color: Color		## Zone color if set to GAIN.
var _drain_zone_color: Color	## Zone color if set to DRAIN.

var _player: Player = null							## Reference to the Player scene.
@onready var _polygon_2d: Polygon2D = $Polygon2D	## Reference to the Wind Zone's Polygon2D child.

## Fetch database resource. If valid, initialize all variables.
func _enter_tree() -> void:
	if (database != null):
		var db_data: Dictionary = database.data
		_initialize_data(db_data)
	else:
		push_error("Database is equal to 'null'.")

func _ready() -> void:
	match mode:
			wind_zone_mode.GAIN:
				_polygon_2d.color = _gain_zone_color
			wind_zone_mode.DRAIN:
				_polygon_2d.color = _drain_zone_color
			_:
				_polygon_2d.color = _gain_zone_color

## If the Player is in the Area2D, gain/drain their wind.
func _physics_process(delta: float) -> void:
	if (_player == null):
		return
	
	var _new_wind_value: float = _player.leaf_meter	## The new value to set the Player's Leaf Meter to.
	
	match mode:
		wind_zone_mode.GAIN:
			_new_wind_value += _wind_gain_rate * delta
		wind_zone_mode.DRAIN:
			_new_wind_value -= _wind_drain_rate * delta
		_:
			return
	
	_player.set_leaf_meter(_new_wind_value)

## Initializes all variables to values extracted from the entity's database.
func _initialize_data(data: Dictionary) -> void:
		_wind_gain_rate = data["wind_gain_rate"]
		_wind_drain_rate = data["wind_drain_rate"]
		_gain_zone_color = data["gain_zone_color"]
		_drain_zone_color = data["drain_zone_color"]

## If body is the Player, keep a reference to them & start wind gain/drain
func _on_body_entered(body: Node2D) -> void:
	if (body is Player):
		_player = body

## If body is the Player, remove Player reference & stop wind gain/drain
func _on_body_exited(body: Node2D) -> void:
	if (body is Player):
		_player = null
