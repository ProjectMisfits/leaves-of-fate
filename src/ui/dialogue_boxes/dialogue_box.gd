extends CanvasLayer
## A basic dialogue balloon for use with Dialogue Manager.

## The texture for the dialogue box currently being used
@onready var dialogue_panel: PanelContainer = $Balloon/MarginContainer/PanelContainer

## The dialogue resource
@export var dialogue_resource: DialogueResource

## Start from a given title when using balloon as a [Node] in a scene.
@export var start_from_title: String = ""

## If running as a [Node] in a scene then auto start the dialogue.
@export var auto_start: bool = false

## The action to use for advancing the dialogue
@export var next_action: StringName = &"ui_accept"

## The action to use to skip typing the dialogue
@export var skip_action: StringName = &"ui_cancel"

## A sound player for voice lines (if they exist).
@onready var beep_speech_player: AudioStreamPlayer = %BeepSpeechPlayer

## A sound player for progressing dialouge
@onready var interact_audio_player: AudioStreamPlayer = $InteractAudio

## Temporary game states
var temporary_game_states: Array = []

## See if we are waiting for the player
var is_waiting_for_input: bool = false

## See if we are running a long mutation and should hide the balloon
var will_hide_balloon: bool = false

## A dictionary to store any ephemeral variables
var locals: Dictionary = {}

var _locale: String = TranslationServer.get_locale()
#Frequency that beep speech is spoken (0 = ever word, 1 = every other word)
var beep_frequency : int = 1
#Current beep count
var cur_beep : int = 0


## The current line
var dialogue_line: DialogueLine:
	set(value):
		if value:
			dialogue_line = value
			apply_dialogue_line()
		else:
			# The dialogue has finished so close the balloon
			if owner == null:
				queue_free()
			else:
				hide()
	get:
		return dialogue_line

## A cooldown timer for delaying the balloon hide when encountering a mutation.
var mutation_cooldown: Timer = Timer.new()

## The base balloon anchor
@onready var balloon: Control = %Balloon

## The label showing the name of the currently speaking character
@onready var character_label: RichTextLabel = %CharacterLabel

## The label showing the currently spoken dialogue
@onready var dialogue_label: DialogueLabel = %DialogueLabel

## Indicator to show that player can progress dialogue.
@onready var progress: TextureRect = %Progress

##Timer for interrupts
@onready var interrupt_timer : Timer = $InterruptTimer

##Character portrait
@onready var character_portrait : TextureRect = %CharacterPortrait

#Determines if the next line should be interrupted
var do_interrupt : bool = false

#Determines how fast the interrupt happens
var interrupt_delay : float 



func _ready() -> void:
	EventBus.interrupt_dialogue.connect(interrupt)
	EventBus.frequency_change.connect(change_frequency)
	balloon.hide()
	Engine.get_singleton("DialogueManager").mutated.connect(_on_mutated)


	mutation_cooldown.timeout.connect(_on_mutation_cooldown_timeout)
	add_child(mutation_cooldown)

	if auto_start:
		if not is_instance_valid(dialogue_resource):
			assert(false, DMConstants.get_error_message(DMConstants.ERR_MISSING_RESOURCE_FOR_AUTOSTART))
		start()

##Function to set the interrupt delay and set the variable to be true
func interrupt(delay:String) -> void:
	interrupt_delay = delay.to_float()
	do_interrupt = true
	
func change_frequency(new_frequency: int) -> void:
	beep_frequency = new_frequency
	cur_beep = 0
	
func _process(_delta: float) -> void:
	if is_instance_valid(dialogue_line):
		progress.visible = not dialogue_label.is_typing  and not dialogue_line.has_tag("voice")


func _unhandled_input(_event: InputEvent) -> void:
	# Only the balloon is allowed to handle input while it's showing
	get_viewport().set_input_as_handled()


func _notification(what: int) -> void:
	## Detect a change of locale and update the current dialogue line to show the new language
	if what == NOTIFICATION_TRANSLATION_CHANGED and _locale != TranslationServer.get_locale() and is_instance_valid(dialogue_label):
		_locale = TranslationServer.get_locale()
		var visible_ratio: float = dialogue_label.visible_ratio
		dialogue_line = await dialogue_resource.get_next_dialogue_line(dialogue_line.id)
		if visible_ratio < 1:
			dialogue_label.skip_typing()


## Start some dialogue
func start(with_dialogue_resource: DialogueResource = null, title: String = "", extra_game_states: Array = []) -> void:
	temporary_game_states = [self] + extra_game_states
	is_waiting_for_input = false
	if is_instance_valid(with_dialogue_resource):
		dialogue_resource = with_dialogue_resource
	if not title.is_empty():
		start_from_title = title
	dialogue_line = await dialogue_resource.get_next_dialogue_line(start_from_title, temporary_game_states)
	show()


## Apply any changes to the balloon given a new [DialogueLine].
func apply_dialogue_line() -> void:
	mutation_cooldown.stop()

	progress.hide()
	is_waiting_for_input = false
	balloon.focus_mode = Control.FOCUS_ALL
	balloon.grab_focus()

	character_label.visible = not dialogue_line.character.is_empty()
	character_label.text = tr(dialogue_line.character, "dialogue")
	
	#Change the texture for the specifc name
	match character_label.text.to_lower():
		"fenn":
			dialogue_panel.add_theme_stylebox_override("panel",ResourceLoader.load("res://src/ui/dialogue_boxes/fenn_dialogue_no_profile.stylebox"))
			character_label.add_theme_color_override("default_color", "#576f35")
			character_portrait.texture = ResourceLoader.load("res://assets/ui/dialogue_boxes/character_portraits/Fenn-Idle-CharacterProfile-001.png")
			beep_speech_player.stream = load("res://assets/dialogue/beep_speech/Player-DialogueBeep-RandomContainer.tres")
		"fenn starry":
			dialogue_panel.add_theme_stylebox_override("panel",ResourceLoader.load("res://src/ui/dialogue_boxes/fenn_dialogue_no_profile.stylebox"))
			character_label.add_theme_color_override("default_color", "#576f35")
			character_portrait.texture = ResourceLoader.load("res://assets/ui/dialogue_boxes/character_portraits/Fenn-StarryEyed-CharacterProfile-001.png")
			beep_speech_player.stream = load("res://assets/dialogue/beep_speech/Player-DialogueBeep-RandomContainer.tres")
			character_label.text = "Fenn"
		"fenn worry":
			dialogue_panel.add_theme_stylebox_override("panel",ResourceLoader.load("res://src/ui/dialogue_boxes/fenn_dialogue_no_profile.stylebox"))
			character_label.add_theme_color_override("default_color", "#576f35")
			character_portrait.texture = ResourceLoader.load("res://assets/ui/dialogue_boxes/character_portraits/Fenn-Worried-CharacterProfile-001.png")
			beep_speech_player.stream = load("res://assets/dialogue/beep_speech/Player-DialogueBeep-RandomContainer.tres")
			character_label.text = "Fenn"
		
		"az":
			dialogue_panel.add_theme_stylebox_override("panel",ResourceLoader.load("res://src/ui/dialogue_boxes/az_dialogue_no_profile.stylebox"))
			character_label.add_theme_color_override("default_color", "#A86A19")
			character_portrait.texture = ResourceLoader.load("res://assets/ui/dialogue_boxes/character_portraits/Az-Idle-CharacterProfile-001.png")
			beep_speech_player.stream = load("res://assets/dialogue/beep_speech/Az-DialogueBeep-RandomContainer.tres")
		"az annoy":
			dialogue_panel.add_theme_stylebox_override("panel",ResourceLoader.load("res://src/ui/dialogue_boxes/az_dialogue_no_profile.stylebox"))
			character_label.add_theme_color_override("default_color", "#A86A19")
			character_portrait.texture = ResourceLoader.load("res://assets/ui/dialogue_boxes/character_portraits/Az-Annoyed-CharacterProfile-001.png")
			beep_speech_player.stream = load("res://assets/dialogue/beep_speech/Az-DialogueBeep-RandomContainer.tres")
			character_label.text = "Az"
		"az laugh":
			dialogue_panel.add_theme_stylebox_override("panel",ResourceLoader.load("res://src/ui/dialogue_boxes/az_dialogue_no_profile.stylebox"))
			character_label.add_theme_color_override("default_color", "#A86A19")
			character_portrait.texture = ResourceLoader.load("res://assets/ui/dialogue_boxes/character_portraits/Az-Laugh-CharacterProfile-001.PNG")
			beep_speech_player.stream = load("res://assets/dialogue/beep_speech/Az-DialogueBeep-RandomContainer.tres")
			character_label.text = "Az"

		"winston":
			dialogue_panel.add_theme_stylebox_override("panel", ResourceLoader.load("res://src/ui/dialogue_boxes/winston_dialogue_no_profile.stylebox"))
			character_label.add_theme_color_override("default_color", "#35639C")
			character_portrait.texture = ResourceLoader.load("res://assets/ui/dialogue_boxes/character_portraits/Winston-Idle-CharacterProfile-001.png")
			beep_speech_player.stream = load("res://assets/dialogue/beep_speech/Ws-DialogueBeep-RandomContainer.tres")
		"winston grit":
			dialogue_panel.add_theme_stylebox_override("panel", ResourceLoader.load("res://src/ui/dialogue_boxes/winston_dialogue_no_profile.stylebox"))
			character_label.add_theme_color_override("default_color", "#35639C")
			character_portrait.texture = ResourceLoader.load("res://assets/ui/dialogue_boxes/character_portraits/Winston-Gritting-CharacterProfile-001.png")
			beep_speech_player.stream = load("res://assets/dialogue/beep_speech/Ws-DialogueBeep-RandomContainer.tres")
			character_label.text = "Winston"
		"winston awkward":
			dialogue_panel.add_theme_stylebox_override("panel", ResourceLoader.load("res://src/ui/dialogue_boxes/winston_dialogue_no_profile.stylebox"))
			character_label.add_theme_color_override("default_color", "#35639C")
			character_portrait.texture = ResourceLoader.load("res://assets/ui/dialogue_boxes/character_portraits/Winston-Awkward-CharacterProfile-001.png")
			beep_speech_player.stream = load("res://assets/dialogue/beep_speech/Ws-DialogueBeep-RandomContainer.tres")
			character_label.text = "Winston"
		"winston hood":
			dialogue_panel.add_theme_stylebox_override("panel", ResourceLoader.load("res://src/ui/dialogue_boxes/winston_dialogue_no_profile.stylebox"))
			character_label.add_theme_color_override("default_color", "#35639C")
			character_portrait.texture = ResourceLoader.load("res://assets/ui/dialogue_boxes/character_portraits/WinstonHooded-Idle-CharacterProfile-001.png")
			beep_speech_player.stream = load("res://assets/dialogue/beep_speech/Ws-DialogueBeep-RandomContainer.tres")
			character_label.text = "Winston"
		"winston hood grit":
			dialogue_panel.add_theme_stylebox_override("panel", ResourceLoader.load("res://src/ui/dialogue_boxes/winston_dialogue_no_profile.stylebox"))
			character_label.add_theme_color_override("default_color", "#35639C")
			character_portrait.texture = ResourceLoader.load("res://assets/ui/dialogue_boxes/character_portraits/WinstonHooded-Gritting-CharacterProfile-001.png")
			beep_speech_player.stream = load("res://assets/dialogue/beep_speech/Ws-DialogueBeep-RandomContainer.tres")
			character_label.text = "Winston"
		"winston hood awkward":			
			dialogue_panel.add_theme_stylebox_override("panel", ResourceLoader.load("res://src/ui/dialogue_boxes/winston_dialogue_no_profile.stylebox"))
			character_label.add_theme_color_override("default_color", "#35639C")
			character_portrait.texture = ResourceLoader.load("res://assets/ui/dialogue_boxes/character_portraits/WinstonHooded-Awkward-CharacterProfile-001.png")
			beep_speech_player.stream = load("res://assets/dialogue/beep_speech/Ws-DialogueBeep-RandomContainer.tres")
			character_label.text = "Winston"
	
		"wizard":
			dialogue_panel.add_theme_stylebox_override("panel", ResourceLoader.load("res://src/ui/dialogue_boxes/winston_dialogue_no_profile.stylebox"))
			character_label.add_theme_color_override("default_color", "#35639C")
			character_portrait.texture = ResourceLoader.load("res://assets/ui/dialogue_boxes/character_portraits/WinstonHooded-Idle-CharacterProfile-001.png")
			beep_speech_player.stream = load("res://assets/dialogue/beep_speech/Ws-DialogueBeep-RandomContainer.tres")
		"wizard grit":
			dialogue_panel.add_theme_stylebox_override("panel", ResourceLoader.load("res://src/ui/dialogue_boxes/winston_dialogue_no_profile.stylebox"))
			character_label.add_theme_color_override("default_color", "#35639C")
			character_portrait.texture = ResourceLoader.load("res://assets/ui/dialogue_boxes/character_portraits/WinstonHooded-Gritting-CharacterProfile-001.png")
			beep_speech_player.stream = load("res://assets/dialogue/beep_speech/Ws-DialogueBeep-RandomContainer.tres")
			character_label.text = "Wizard"
		"wizard awkward":
			dialogue_panel.add_theme_stylebox_override("panel", ResourceLoader.load("res://src/ui/dialogue_boxes/winston_dialogue_no_profile.stylebox"))
			character_label.add_theme_color_override("default_color", "#35639C")
			character_portrait.texture = ResourceLoader.load("res://assets/ui/dialogue_boxes/character_portraits/WinstonHooded-Awkward-CharacterProfile-001.png")
			beep_speech_player.stream = load("res://assets/dialogue/beep_speech/Ws-DialogueBeep-RandomContainer.tres")
			character_label.text = "Wizard"


		"wizard?":
			dialogue_panel.add_theme_stylebox_override("panel", ResourceLoader.load("res://src/ui/dialogue_boxes/winston_dialogue_no_profile.stylebox"))
			character_label.add_theme_color_override("default_color", "#35639C")
			character_portrait.texture = ResourceLoader.load("res://assets/ui/dialogue_boxes/character_portraits/WinstonHooded-Idle-CharacterProfile-001.png")
			beep_speech_player.stream = load("res://assets/dialogue/beep_speech/Ws-DialogueBeep-RandomContainer.tres")
		"??? ws grit":
			dialogue_panel.add_theme_stylebox_override("panel", ResourceLoader.load("res://src/ui/dialogue_boxes/winston_dialogue_no_profile.stylebox"))
			character_label.add_theme_color_override("default_color", "#35639C")
			character_portrait.texture = ResourceLoader.load("res://assets/ui/dialogue_boxes/character_portraits/WinstonHooded-Gritting-CharacterProfile-001.png")
			beep_speech_player.stream = load("res://assets/dialogue/beep_speech/Ws-DialogueBeep-RandomContainer.tres")
			character_label.text = "???"
		"??? ws awkward":
			dialogue_panel.add_theme_stylebox_override("panel", ResourceLoader.load("res://src/ui/dialogue_boxes/winston_dialogue_no_profile.stylebox"))
			character_label.add_theme_color_override("default_color", "#35639C")
			character_portrait.texture = ResourceLoader.load("res://assets/ui/dialogue_boxes/character_portraits/WinstonHooded-Awkward-CharacterProfile-001.png")
			beep_speech_player.stream = load("res://assets/dialogue/beep_speech/Ws-DialogueBeep-RandomContainer.tres")
			character_label.text = "???"

		"??? ws":
			dialogue_panel.add_theme_stylebox_override("panel", ResourceLoader.load("res://src/ui/dialogue_boxes/winston_dialogue_no_profile.stylebox"))
			character_label.add_theme_color_override("default_color", "#35639C")
			character_portrait.texture = ResourceLoader.load("res://assets/ui/dialogue_boxes/character_portraits/WinstonHooded-Idle-CharacterProfile-001.png")
			beep_speech_player.stream = load("res://assets/dialogue/beep_speech/Ws-DialogueBeep-RandomContainer.tres")
			character_label.text = "???"

		"test":
			dialogue_panel.add_theme_stylebox_override("panel",ResourceLoader.load("res://src/ui/dialogue_boxes/plain_dialogue_no_profile.stylebox"))
			character_label.add_theme_color_override("default_color", "#352620")
			character_portrait.texture = null
			beep_speech_player.stream = load("res://assets/dialogue/beep_speech/Default-DialogueBeep-RandomContainer.tres")
		"??? door":
			dialogue_panel.add_theme_stylebox_override("panel",ResourceLoader.load("res://src/ui/dialogue_boxes/wizard_of_doors_dialogue_no_profile.stylebox"))
			character_label.add_theme_color_override("default_color", "#6B2D76")
			character_portrait.texture = null
			beep_speech_player.stream = load("res://assets/dialogue/beep_speech/Default-DialogueBeep-RandomContainer.tres")
			character_label.text = "???"
		
		"???":
			dialogue_panel.add_theme_stylebox_override("panel",ResourceLoader.load("res://src/ui/dialogue_boxes/plain_dialogue_no_profile.stylebox"))
			character_label.add_theme_color_override("default_color", "#352620")
			character_portrait.texture = null
			beep_speech_player.stream = load("res://assets/dialogue/beep_speech/Default-DialogueBeep-RandomContainer.tres")
			
		_:
			dialogue_panel.add_theme_stylebox_override("panel",ResourceLoader.load("res://src/ui/dialogue_boxes/plain_dialogue_no_profile.stylebox"))
			character_label.add_theme_color_override("default_color", "#352620")
			character_portrait.texture = null
			beep_speech_player.stream = load("res://assets/dialogue/beep_speech/Default-DialogueBeep-RandomContainer.tres")
	
	dialogue_label.hide()
	dialogue_label.dialogue_line = dialogue_line

	# Show our balloon
	balloon.show()
	will_hide_balloon = false

	dialogue_label.show()
	if not dialogue_line.text.is_empty():
		dialogue_label.type_out()
		await dialogue_label.finished_typing

	# Wait for next line
	if dialogue_line.has_tag("voice"):

		beep_speech_player.stream = load(dialogue_line.get_tag_value("voice"))
		beep_speech_player.play()
		await beep_speech_player.finished
		next(dialogue_line.next_id)
	elif dialogue_line.time != "":
		
		var time: float = dialogue_line.text.length() * 0.02 if dialogue_line.time == "auto" else dialogue_line.time.to_float()
		await get_tree().create_timer(time).timeout
		next(dialogue_line.next_id)
	else:
	
		is_waiting_for_input = true
		balloon.focus_mode = Control.FOCUS_ALL
		balloon.grab_focus()
		if(do_interrupt):
			print(interrupt_delay)
			interrupt_timer.start(interrupt_delay)

## Go to the next line
func next(next_id: String) -> void:
	dialogue_line = await dialogue_resource.get_next_dialogue_line(next_id, temporary_game_states)


#region Signals


func _on_mutation_cooldown_timeout() -> void:
	if will_hide_balloon:
		will_hide_balloon = false
		balloon.hide()


func _on_mutated(_mutation: Dictionary) -> void:
	if not _mutation.is_inline:
		is_waiting_for_input = false
		will_hide_balloon = true
		mutation_cooldown.start(0.1)


func _on_balloon_gui_input(event: InputEvent) -> void:
	# See if we need to skip typing the dialogue
	if dialogue_label.is_typing:
		if event.is_action_pressed("ui_accept"):
			get_viewport().set_input_as_handled()
			dialogue_label.skip_typing()
			return
	
	# Don't respond to input if waiting for input
	if not is_waiting_for_input: return

	# When there are no response options the balloon itself is the clickable thing
	elif event.is_action_pressed("ui_accept") and get_viewport().gui_get_focus_owner() == balloon:
		get_viewport().set_input_as_handled()
		interact_audio_player.play()
		do_interrupt = false
		next(dialogue_line.next_id)


#endregion


func _on_dialogue_label_spoke(letter: String, _letter_index: int, _speed: float) -> void:
	#don't make sounds on space
	if not letter in [" ", ".","!","?",","] and cur_beep == 0:
		beep_speech_player.play()
		cur_beep = beep_frequency
	elif not letter in [" ", ".","!","?",","] :
		cur_beep -= 1

func _on_interrupt_timer_timeout() -> void:
	if(do_interrupt):
		next(dialogue_line.next_id)
		do_interrupt = false
