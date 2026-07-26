extends Node2D

const MM_SPRITE_ANGRY = preload("uid://cbkngg2bsj150")
const MM_SPRITE_FLUSTERED = preload("uid://b8w0ta154motm")
const MM_SPRITE_LAUGH = preload("uid://b48j3ymvrht04")
const MM_SPRITE_NEUTRAL = preload("uid://bvigysf356rdi")
const MM_SPRITE_SADGE = preload("uid://cbd2d1tq6yk0a")

const BAE_SPRITE_ANGRY = preload("uid://cmxipkf166231")
const BAE_SPRITE_GIGGLY = preload("uid://cijok6ncqro5a")
const BAE_SPRITE_NEUTRAL = preload("uid://dsrqpkltvwpnc")
const BAE_SPRITE_SADGE = preload("uid://h865nanm1veu")
const BAE_SPRITE_SCARED = preload("uid://byugc72hf3exs")

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
	if not GameGlobals.audio_manager.persistent_audio.has("music_title"):
		GameGlobals.audio_manager.create_persistent_audio("music_title")
	dialog.dialog_changed.connect(_on_dialog_changed)
	dialog.active = true
	get_tree().paused = false


func _process(delta: float) -> void:
	if Input.is_action_pressed("ultimate"):
		skip_time -= delta
		if skip_time <= 0:
			skipping = true
			GameGlobals.audio_manager.fade_persistent_audio_out_and_destroy("music_title", 1)
			GameUi.ui_transitions.change_scene("res://game/main/main_game_scene.tscn")
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
		crush_sprite_2d.texture = BAE_SPRITE_SCARED

	# crush neutral
	if dialog.dialog_index == 4:
		crush_sprite_2d.texture = BAE_SPRITE_NEUTRAL

	# moth appears
	# moth neutral
	if dialog.dialog_index == 5:
		animation_player.play("moth_on")
		moth_sprite_2d.texture = MM_SPRITE_NEUTRAL

	# moth flustered
	if dialog.dialog_index == 7:
		moth_sprite_2d.texture = MM_SPRITE_FLUSTERED

	# crush flirty
	if dialog.dialog_index == 10:
		crush_sprite_2d.texture = BAE_SPRITE_GIGGLY

	# moth angry
	if dialog.dialog_index == 11:
		moth_sprite_2d.texture = MM_SPRITE_ANGRY

	# moth sad
	if dialog.dialog_index == 12:
		moth_sprite_2d.texture = MM_SPRITE_SADGE

	# crush neutral
	if dialog.dialog_index == 13:
		crush_sprite_2d.texture = BAE_SPRITE_NEUTRAL

	# crush angry
	if dialog.dialog_index == 15:
		crush_sprite_2d.texture = BAE_SPRITE_ANGRY

	# crush neutral
	if dialog.dialog_index == 16:
		crush_sprite_2d.texture = BAE_SPRITE_NEUTRAL

	# crush flirty
	if dialog.dialog_index == 19:
		crush_sprite_2d.texture = BAE_SPRITE_GIGGLY

	# crush neutral
	if dialog.dialog_index == 22:
		crush_sprite_2d.texture = BAE_SPRITE_NEUTRAL

	# moth laughing
	if dialog.dialog_index == 23:
		moth_sprite_2d.texture = MM_SPRITE_LAUGH

	# crush flirty
	if dialog.dialog_index == 24:
		crush_sprite_2d.texture = BAE_SPRITE_GIGGLY

	# crush neutral
	if dialog.dialog_index == 25:
		crush_sprite_2d.texture = BAE_SPRITE_NEUTRAL

	# moth flustered
	if dialog.dialog_index == 27:
		moth_sprite_2d.texture = MM_SPRITE_FLUSTERED

	# crush scared
	if dialog.dialog_index == 28:
		crush_sprite_2d.texture = BAE_SPRITE_SCARED

	# moth angry
	if dialog.dialog_index == 29:
		moth_sprite_2d.texture = MM_SPRITE_ANGRY

	# moth disappears
	# crush neutral
	if dialog.dialog_index == 33:
		animation_player.play("moth_off")

	# change to game
	if dialog.dialog_index == 34:
		GameGlobals.audio_manager.fade_persistent_audio_out_and_destroy("music_title", 1)
		GameUi.ui_transitions.change_scene("res://game/main/main_game_scene.tscn")
