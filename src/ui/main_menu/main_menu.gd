class_name MainMenu extends Control
## The main menu for the game.

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$CanvasLayer/MainSelectionsContainer/PlayButton.grab_focus.call_deferred()

func _process(delta: float) -> void:
	_escape_menus()

# Signals that the game is started.
func _on_play_button_button_up() -> void:
	# SceneManager.swap_scenes("res://src/ui/intro_letter/intro_letter.tscn", null, self)
	SceneManager.swap_scenes("res://src/gameplay/gameplay.tscn", null, self)

func _hide_main_menu() -> void:
	
	$CanvasLayer/EnvelopeBase.hide()
	$CanvasLayer/MainSelectionsContainer.hide()

func _show_main_menu() -> void:
	$CanvasLayer/EnvelopeBase.show()
	$CanvasLayer/MainSelectionsContainer.show()
	$CanvasLayer/MainSelectionsContainer/PlayButton.grab_focus.call_deferred()

# Open settings menu when corresponding button is pressed
func _on_settings_button_up() -> void:
	_hide_main_menu()
	add_child(preload("res://src/ui/settings_menu/settings_menu.tscn").instantiate())
	
	# maps settings menu signals to corresponding functions in gameplay.gd
	$SettingsMenu/CanvasLayer/Panel/ControlsContainer/BackButton.button_up.connect(_exit_settings)
	$SettingsMenu/CanvasLayer/Panel/ControlsContainer/VolumeButton.button_up.connect(_open_volume)
	$SettingsMenu/CanvasLayer/Panel/ControlsContainer/ControlsButton.button_up.connect(_open_controls)

# Open controls menu when corresponding button is pressed
func _on_return_label_button_up() -> void:
	_open_controls()

# Closes game when exit button pressed
func _on_exit_button_up() -> void:
	get_tree().quit()

# Exits setting menu back to pause menu
func _exit_settings() -> void:
	# removes settings menu and opens new pause menu
	$SettingsMenu.queue_free()
	_show_main_menu()

# Opens volume menu from settings menu
func _open_volume() -> void:
	# creates volume menu as child of settings and hides settings menu
	$SettingsMenu.add_child(preload("res://src/ui/settings_menu/volume_menu/volume_menu.tscn").instantiate())
	$SettingsMenu.hide()
	
	# maps volume back signal to corresponding function
	$SettingsMenu/VolumeMenu/CanvasLayer/Panel/BackButton.button_up.connect(_close_volume)

# Closes volume menu 
func _close_volume() -> void:
	# removes volume menu and unhides settings menu 
	$SettingsMenu/VolumeMenu.queue_free()
	$SettingsMenu.show()
	# gives top button of settings menu focus again
	$SettingsMenu/CanvasLayer/Panel/ControlsContainer/ControlsButton.grab_focus.call_deferred()

# Opens controls menu from settings menu
func _open_controls() -> void:
	if has_node("SettingsMenu"): 
		# creates controls menu as child of settings and hides settings menu
		$SettingsMenu.add_child(preload("res://src/ui/settings_menu/controls_menu/controls_menu.tscn").instantiate())
		$SettingsMenu.hide()
		# maps controls back signal to corresponding function
		$SettingsMenu/ControlsMenu/CanvasLayer/Panel/BackButton.button_up.connect(_close_controls)
	else: 
		# creates controls menu as child of main menu and hides main menu
		add_child(preload("res://src/ui/settings_menu/controls_menu/controls_menu.tscn").instantiate())
		_hide_main_menu()
		# maps controls back signal to corresponding function
		$ControlsMenu/CanvasLayer/Panel/BackButton.button_up.connect(_close_controls)

# Closes controls menu 
func _close_controls() -> void:
	if has_node("SettingsMenu"):
		# removes controls menu and unhides settings menu
		$SettingsMenu/ControlsMenu.queue_free()
		$SettingsMenu.show()
		# gives top button of settings menu focus again
		$SettingsMenu/CanvasLayer/Panel/ControlsContainer/ControlsButton.grab_focus.call_deferred()
	else:
		# removes controls menu and unides main menu
		$ControlsMenu.queue_free()
		_show_main_menu()

func _escape_menus() -> void:
	if Input.is_action_just_pressed(&"pause"):
		if (has_node("SettingsMenu")):
			_exit_settings()
		elif (has_node("ControlsMenu")):
			_close_controls()
