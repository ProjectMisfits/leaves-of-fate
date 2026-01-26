extends HSlider

# bus name variable, case sensitive
@export
var bus_name: String

# corresponding index to the bus based on the name given
var bus_index: int 

# set up slider
func _ready() -> void:
	# get bus index from given 
	bus_index = AudioServer.get_bus_index(bus_name)
	# update value when slider is changed 
	value_changed.connect(_on_value_changed)
	# set values to what volume is currently set to
	value = db_to_linear(AudioServer.get_bus_volume_db(bus_index))

# update volume to what the slider indicates
func _on_value_changed(val: float) -> void:
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(val))
