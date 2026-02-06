extends Button

#get leaf pointer child (should be only child)
@onready var my_leaf_pointer: TextureRect = $LeafPointer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Connect Hover (uncomment to activate)
	#connect("mouse_entered", Callable(self, "_leaf_pointer_on"))
	#connect("mouse_exited", Callable(self, "_leaf_pointer_off"))
	
	# Connect focus
	connect("focus_entered", Callable(self, "_leaf_pointer_on"))
	connect("focus_exited", Callable(self, "_leaf_pointer_off"))
	
	# Start hidden
	my_leaf_pointer.hide()
	
# Show leaf pointer
func _leaf_pointer_on() -> void:
	my_leaf_pointer.show()

# Hide leaf pointer
func _leaf_pointer_off() -> void:
	my_leaf_pointer.hide()
