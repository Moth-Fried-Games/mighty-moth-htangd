@tool
class_name Dialog
extends Node2D

@onready var ui_dialog: UIDialog = $UIDialog

## Activate this Dialog if true. Can be set by Activators like InteractibleComponent.
@export var active: bool = false
## Hide after dialog is finished?
@export var hide_on_finish: bool = true
## Allow dialog to be advanced with input if true.
@export var input_dialog: bool = false
## Make this a UI Conversation if true.
@export var conversation_dialog: bool = false
## Automatically advance dialog on a timer if true.
@export var auto_dialog: bool = false
## Time before advancing dialog automatically.
@export var auto_time: float = 2
## Dialog will loop if true, does not work if Input is enabled.
@export var auto_loop: bool = false
## List of Dialogs, BBCode Allowed.
@export_multiline("Dialog") var dialog_list: Array[String] = []
## Pixel Width for the Dialog
@export_range(24, 240) var dialog_width: float = 72
## Dialog Index to Preview in the Editor.
@export var preview_dialog_index: int = 0:
	set(v):
		if dialog_list.is_empty():
			preview_dialog_index = 0
		else:
			preview_dialog_index = clampi(v, 0, dialog_list.size() - 1)

var dialog_timer: Timer = null
var dialog_index: int = 0
var dialog_playing: bool = false
var dialog_finished: bool = true
var hiding_finished: bool = false
var input_grabbed: bool = false


func _enter_tree() -> void:
	add_to_group("dialog")


func _ready() -> void:
	z_index = 10
	if not Engine.is_editor_hint():
		if active:
			ui_dialog.modulate.a = 1
		else:
			ui_dialog.modulate.a = 0
		if conversation_dialog:
			ui_dialog.queue_free()
			ui_dialog = null
	dialog_timer = Timer.new()
	dialog_timer.one_shot = true
	dialog_timer.timeout.connect(_on_dialog_timeout)
	add_child(dialog_timer)
	if is_instance_valid(ui_dialog):
		ui_dialog.typing_finished.connect(_on_typing_finished)


func _process(delta: float) -> void:
	if not Engine.is_editor_hint():
		update_conversation()
		if active:
			play_dialog()
			hide_on_obstruction()
		else:
			if hide_on_finish and hiding_finished:
				hiding_finished = false
				dialog_index = 0
				if conversation_dialog:
					ui_dialog.typing_finished.disconnect(_on_typing_finished)
					ui_dialog = null
			if is_instance_valid(ui_dialog):
				if ui_dialog.modulate.a != 0:
					ui_dialog.toggle_hide_tween(false)
					ui_dialog.reset_text = true
		adjust_dialog()
	else:
		tool_procress(delta)


func _physics_process(_delta: float) -> void:
	if not Engine.is_editor_hint():
		input_focus()
		process_input()


func tool_procress(_delta: float) -> void:
	adjust_dialog()
	if not dialog_list.is_empty():
		if ui_dialog.text != dialog_list[preview_dialog_index]:
			if not input_dialog:
				ui_dialog.message(dialog_list[preview_dialog_index])
			else:
				ui_dialog.ui_inputs = ["accept Next"]
				ui_dialog.message_input(dialog_list[preview_dialog_index])
	else:
		if ui_dialog.text != "":
			ui_dialog.clear()
	if active:
		if ui_dialog.modulate.a != 1:
			ui_dialog.modulate.a = 1
	else:
		if ui_dialog.modulate.a != 0.75:
			ui_dialog.modulate.a = 0.75


func adjust_dialog() -> void:
	if not is_instance_valid(ui_dialog):
		return
	if not Engine.is_editor_hint() and conversation_dialog:
		var conversation_x: float = (299 - ui_dialog.size.x) / 2
		if ui_dialog.position.x != conversation_x:
			ui_dialog.position.x = conversation_x
		var conversation_y: float = 168 - ui_dialog.size.y - 20
		if ui_dialog.position.y != conversation_y:
			ui_dialog.position.y = conversation_y
		return
	if ui_dialog.custom_minimum_size.x != dialog_width:
		ui_dialog.custom_minimum_size.x = dialog_width
		ui_dialog.size.x = dialog_width
		ui_dialog.clear()
	if ui_dialog.position.x != -ui_dialog.size.x / 2:
		ui_dialog.position.x = -ui_dialog.size.x / 2
	if ui_dialog.position.y != -ui_dialog.size.y:
		ui_dialog.position.y = -ui_dialog.size.y


func update_conversation() -> void:
	if conversation_dialog:
		if not is_instance_valid(ui_dialog):
			ui_dialog = GameGlobals.game_dictionary["node"]["conversation"]
			ui_dialog.typing_finished.connect(_on_typing_finished)


func play_dialog() -> void:
	if not dialog_list.is_empty():
		if ui_dialog.text != dialog_list[dialog_index]:
			dialog_playing = true
			dialog_finished = false
			if not input_dialog:
				ui_dialog.message(dialog_list[dialog_index])
			else:
				ui_dialog.ui_inputs = ["accept Next"]
				ui_dialog.message_input(dialog_list[dialog_index])


func input_focus() -> void:
	if active and input_dialog and not dialog_finished and not hiding_finished:
		if not input_grabbed:
			GameGlobals.game_dictionary["node"]["input_focus"] = self
			input_grabbed = true
	else:
		if input_grabbed:
			GameGlobals.game_dictionary["node"]["input_focus"] = null
			input_grabbed = false


func process_input() -> void:
	if not active or not input_dialog:
		return
	var accept_input: bool = Input.is_action_just_pressed("ui_accept")
	if accept_input:
		if not ui_dialog.text_finished:
			ui_dialog.finish_typing()
		else:
			if not dialog_timer.is_stopped():
				dialog_timer.stop()
			next_dialog()


func next_dialog() -> void:
	if dialog_index < dialog_list.size() - 1:
		dialog_index += 1
	else:
		if auto_loop and not input_dialog:
			dialog_index = 0
		else:
			if hide_on_finish:
				if not hiding_finished:
					dialog_playing = false
					dialog_finished = true
					hiding_finished = true


func _on_typing_finished() -> void:
	if dialog_index <= dialog_list.size() - 1:
		if auto_dialog:
			dialog_timer.start(auto_time)
	else:
		if not hide_on_finish:
			dialog_playing = false
			dialog_finished = true
			hiding_finished = true


func _on_dialog_timeout() -> void:
	next_dialog()


func hide_on_obstruction() -> void:
	if hide_on_finish and hiding_finished:
		ui_dialog.toggle_hide_tween(false)
		return
	if conversation_dialog:
		ui_dialog.toggle_hide_tween(true)
		return
