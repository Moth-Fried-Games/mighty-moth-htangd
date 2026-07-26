extends Node2D

@onready var dialog: Dialog = $Dialog
@onready var moth_sprite_2d: Sprite2D = $MothSprite2D
@onready var crush_sprite_2d: Sprite2D = $CrushSprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var skip_rich_text_label: RichTextLabel = $CanvasLayer/SkipRichTextLabel

var skip_time: float = 1
var skipping: bool = false


func _ready() -> void:
	GameUi.ui_transitions.toggle_transition(false)
	skip_rich_text_label.modulate.a = 0
	await get_tree().create_timer(1).timeout
	if not GameGlobals.audio_manager.persistent_audio.has("music_good"):
		GameGlobals.audio_manager.create_persistent_audio("music_good")
	dialog.dialog_changed.connect(_on_dialog_changed)
	dialog.active = true


func _process(delta: float) -> void:
	if Input.is_action_pressed("ultimate"):
		skip_time -= delta
		if skip_time <= 0:
			skipping = true
			GameGlobals.audio_manager.fade_persistent_audio_out_and_destroy("music_good", 1)
			GameUi.ui_transitions.change_scene("res://game/title/menu.tscn")
	else:
		if skip_time != 1:
			skip_time = 1
	if skipping or skip_time < 1:
		skip_rich_text_label.modulate.a = 1 - (skip_time / 1)
	else:
		if skip_rich_text_label.modulate.a > 0:
			skip_rich_text_label.modulate.a -= delta
			skip_rich_text_label.modulate.a = clampf(skip_rich_text_label.modulate.a, 0, 1)


func _on_dialog_changed() -> void:
	if dialog.dialog_index == 0:
		animation_player.play("RESET")

	# shake screen
	if dialog.dialog_index == 2:
		pass

	# crush appears
	# crush scared
	if dialog.dialog_index == 3:
		animation_player.play("crush_on")

	# crush neutral
	if dialog.dialog_index == 4:
		pass

	# moth appears
	# moth neutral
	if dialog.dialog_index == 5:
		animation_player.play("moth_on")

	# moth flustered
	if dialog.dialog_index == 7:
		pass

	# crush flirty
	if dialog.dialog_index == 10:
		pass

	# moth angry
	if dialog.dialog_index == 11:
		pass

	# moth sad
	if dialog.dialog_index == 12:
		pass

	# crush neutral
	if dialog.dialog_index == 13:
		pass

	# crush angry
	if dialog.dialog_index == 15:
		pass

	# crush neutral
	if dialog.dialog_index == 16:
		pass

	# crush flirty
	if dialog.dialog_index == 19:
		pass

	# crush neutral
	if dialog.dialog_index == 22:
		pass

	# moth laughing
	if dialog.dialog_index == 23:
		pass

	# crush flirty
	if dialog.dialog_index == 24:
		pass

	# crush neutral
	if dialog.dialog_index == 25:
		pass

	# moth flustered
	if dialog.dialog_index == 27:
		pass

	# crush scared
	if dialog.dialog_index == 28:
		pass

	# moth angry
	if dialog.dialog_index == 29:
		pass

	# moth disappears
	# crush neutral
	if dialog.dialog_index == 33:
		animation_player.play("moth_off")

	# change to game
	if dialog.dialog_index == 34:
		GameGlobals.audio_manager.fade_persistent_audio_out_and_destroy("music_title", 1)
		GameUi.ui_transitions.change_scene("res://game/main/main_game_scene.tscn")
