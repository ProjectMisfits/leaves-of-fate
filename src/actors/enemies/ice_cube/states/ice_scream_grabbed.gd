extends LimboState
#exists as a delay for godot so the ice cube is not released by the same trigger
var delay: bool = false
# Called when the node enters the scene tree for the first time.
func _enter() -> void:
	print("Entered Grabbed State")
	agent.grab()
	delay = false
	pass


func _update(_delta: float) -> void:
	agent.check_release(delay)
	delay = true
	pass
