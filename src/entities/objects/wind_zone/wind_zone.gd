## Wind Zones force the Player to Leaf Dash or prevent the Player from Leaf Dashing while in
## the zone, depending on the set mode. The Player's Leaf Meter does not change while in the zone.
extends Area2D
class_name WindZone

enum wind_zone_mode {DASH, NO_DASH}	## Mode for Wind Zones.


@export var database: JSON = null						## JSON Resource containing numerical data.
@export var mode: wind_zone_mode = wind_zone_mode.DASH	## Determines whether the Wind Zone will force or prevent Leaf Dashing

var _dash_zone_color: Color		## Zone color if set to DASH.
var _no_dash_zone_color: Color	## Zone color if set to NO_DASH.

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
			wind_zone_mode.DASH:
				_polygon_2d.color = _dash_zone_color
			wind_zone_mode.NO_DASH:
				_polygon_2d.color = _no_dash_zone_color
			_:
				_polygon_2d.color = _dash_zone_color

## Initializes all variables to values extracted from the entity's database.
func _initialize_data(data: Dictionary) -> void:
		_dash_zone_color = data["dash_zone_color"]
		_no_dash_zone_color = data["no_dash_zone_color"]

## If body is the Player, change the Player's leaf dash mode depending on mode.
func _on_body_entered(body: Node2D) -> void:
	if (body is Player):
		match mode:
			wind_zone_mode.DASH:
				body.set_current_leaf_dash_mode(Player.leaf_dash_mode.DASH_ONLY)
			wind_zone_mode.NO_DASH:
				body.set_current_leaf_dash_mode(Player.leaf_dash_mode.NO_DASH)
			_:
				return

## If body is the Player, revert Player's leaf dash mode to normal.
func _on_body_exited(body: Node2D) -> void:
	if (body is Player):
		body.set_current_leaf_dash_mode(Player.leaf_dash_mode.NORMAL)
