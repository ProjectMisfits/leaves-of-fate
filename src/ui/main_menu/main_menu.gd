class_name MainMenu extends Control
## The main menu for the game.

## A reference to the MenuHolder CanvasLayer.
@onready var menu_holder = %SubmenuHolder
## A reference to the settings menu scene.
@onready var settings_menu: SettingsMenu = preload("res://src/ui/settings_menu/settings_menu.tscn").instantiate()
## A reference to the controls menu scene.
@onready var controls_menu: ControlsMenu = preload("res://src/ui/settings_menu/controls_menu/controls_menu.tscn").instantiate()
## A reference to the volume menu scene.
@onready var volume_menu: VolumeMenu = preload("res://src/ui/settings_menu/volume_menu/volume_menu.tscn").instantiate()
## A reference to the controls menu scene.
@onready var credits_menu: CreditsMenu = preload("res://src/ui/main_menu/credits/credits.tscn").instantiate()
## An audio player for the select sound effect.
@onready var select_audio: AudioStreamPlayer = $Audio/SelectAudio

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if(!SaveManager._check_save()):
		$%ContinueButton.hide()
	_connect_menu_signals()
	get_node("%NewButton").grab_focus.call_deferred()

func _process(_delta: float) -> void:
	_escape_menus()

# Signals that the game is started.
func _on_play_button_button_up() -> void:
	select_audio.play()
	await select_audio.finished
	#Creates new save files
	EventFlags.reset_all_flags()
	SaveManager._save_room("res://src/rooms/01_great_hall/01_GreatHall_a_Intro_room.tscn")
	SaveManager._save_flags()
	#Loads intro letter
	SceneManager.swap_scenes_with_transition("res://src/ui/intro_letter/intro_letter.tscn", null, self)

# Signals that the game is started.
func _on_continue_button_button_up() -> void:
	select_audio.play()
	await select_audio.finished
	#Loads data from save files
	SaveManager._load_flags()
	SaveManager._load_room()
	#Loads room saved in save file
	SceneManager.swap_scenes_with_transition("res://src/gameplay/gameplay.tscn", null, self)

func _hide_main_menu() -> void:
	get_node("%EnvelopeBase").hide()
	get_node("%MainSelectionsContainer").hide()

func _show_main_menu() -> void:
	get_node("%EnvelopeBase").show()
	get_node("%MainSelectionsContainer").show()
	get_node("%NewButton").grab_focus.call_deferred()

# Closes game when exit button pressed
func _on_exit_button_up() -> void:
	get_tree().quit()

# lets you use escape to exit out of a menu 
func _escape_menus() -> void:
	if Input.is_action_just_pressed(&"pause"):
		for menu: Control in menu_holder.get_children():
			menu_holder.remove_child(menu)
		_show_main_menu()

func _connect_menu_signals() -> void:
	# Connect settings menu
	settings_menu.get_node("%ControlsButton").button_up.connect(_open_controls_menu)
	settings_menu.get_node("%VolumeButton").button_up.connect(_open_volume_menu)
	settings_menu.get_node("%BackButton").button_up.connect(close_settings_menu)
	# Connect controls menu
	controls_menu.get_node("%BackButton").button_up.connect(close_controls_menu)
	# Connect volume menu
	volume_menu.get_node("%BackButton").button_up.connect(close_volume_menu)
	#Connect credits menu
	credits_menu.get_node("%BackButton").button_up.connect(close_credits_menu)

# Opens settings menu
func _open_settings_menu() -> void:
	select_audio.play()
	menu_holder.add_child(settings_menu)
	_hide_main_menu()
	settings_menu.get_node("%ControlsButton").grab_focus.call_deferred()

# Closes setting menuhas_node("res://src/ui/settings_menu/settings_menu.tscn")
func close_settings_menu() -> void:
	select_audio.play()
	get_node("%NewButton").grab_focus.call_deferred()
	_show_main_menu()
	menu_holder.remove_child(settings_menu)

# Opens volume menu
func _open_volume_menu() -> void:
	select_audio.play()
	menu_holder.add_child(volume_menu)
	volume_menu.get_node("%MasterSlider").grab_focus.call_deferred()

# Closes volume menu
func close_volume_menu() -> void:
	select_audio.play()
	settings_menu.get_node("%ControlsButton").grab_focus.call_deferred()
	menu_holder.remove_child(volume_menu)

# Opens controls menu
func _open_controls_menu() -> void:
	select_audio.play()
	if not menu_holder.has_node("SettingsMenu"):
		_hide_main_menu()
	
	menu_holder.add_child(controls_menu)
	controls_menu.get_node("%BackButton").grab_focus.call_deferred()

# Closes controls menu 
func close_controls_menu() -> void:
	select_audio.play()
	if not menu_holder.has_node("SettingsMenu"):
		_show_main_menu()
		$%NewButton.grab_focus.call_deferred()
	else:
		settings_menu.get_node("%ControlsButton").grab_focus.call_deferred()
	menu_holder.remove_child(controls_menu)

# Opens Credits menu
func _open_credits_menu() -> void:
	select_audio.play()
	if not menu_holder.has_node("SettingsMenu"):
		_hide_main_menu()
	
	menu_holder.add_child(credits_menu)
	credits_menu.get_node("%BackButton").grab_focus.call_deferred()

# Closes controls menu 
func close_credits_menu() -> void:
	select_audio.play()
	_show_main_menu()
	$%NewButton.grab_focus.call_deferred()
	menu_holder.remove_child(credits_menu)
	credits_menu.get_node("%ScrollContainer").scroll_vertical = 0
	credits_menu.was_closed = true
