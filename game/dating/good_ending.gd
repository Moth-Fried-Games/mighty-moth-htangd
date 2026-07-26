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
	if not GameGlobals.audio_manager.persistent_audio.has("music_better"):
		GameGlobals.audio_manager.create_persistent_audio("music_better")
	dialog.dialog_changed.connect(_on_dialog_changed)
	dialog.active = true
	get_tree().paused = false


func _process(delta: float) -> void:
	if Input.is_action_pressed("ultimate"):
		skip_time -= delta
		if skip_time <= 0:
			skipping = true
			GameGlobals.audio_manager.fade_persistent_audio_out_and_destroy("music_better", 1)
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

	# change to game
	if dialog.dialog_index == 1:
		GameGlobals.audio_manager.fade_persistent_audio_out_and_destroy("music_better", 1)
		GameUi.ui_transitions.change_scene("res://game/main/main_game_scene.tscn")
