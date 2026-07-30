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

const GRUNT_SPRITE_ANGRY = preload("uid://tixgpqj0qad8")
const GRUNT_SPRITE_BEATENUP = preload("uid://bm0jpam4m3c2")
const GRUNT_SPRITE_EVILLAUGH = preload("uid://hjt41n7ytka4")
const GRUNT_SPRITE_NEUTRAL = preload("uid://5gmchrmlyxhj")

@onready var anchor: Node2D = $Anchor
@onready var dialog: Dialog = $Anchor/Dialog
@onready var moth_sprite_2d: Sprite2D = $Anchor/MothSprite2D
@onready var crush_sprite_2d: Sprite2D = $Anchor/CrushSprite2D
@onready var goon_sprite_2d: Sprite2D = $Anchor/GoonSprite2D
@onready var animation_player: AnimationPlayer = $Anchor/AnimationPlayer
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
	get_tree().paused = false
	animation_player.play("RESET")
	animation_player.play("crush_on")


func _process(delta: float) -> void:
	var viewport_length: float = get_viewport_rect().size.x
	if viewport_length > 1280:
		if anchor.position.x != ((viewport_length - 1280) / 2):
			anchor.position.x = ((viewport_length - 1280) / 2)
	else:
		if anchor.position.x != 0:
			anchor.position.x = 0
	if Input.is_action_pressed("ultimate"):
		skip_time -= delta
		if not skipping and skip_time <= 0:
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
	# crush neutral
	# crush appears
	if dialog.dialog_index == 0:
		crush_sprite_2d.texture = BAE_SPRITE_NEUTRAL
		animation_player.play("crush_on")

	# moth neutral
	# moth appears
	if dialog.dialog_index == 3:
		moth_sprite_2d.texture = MM_SPRITE_NEUTRAL
		animation_player.play("moth_on")

	# moth angry
	if dialog.dialog_index == 5:
		moth_sprite_2d.texture = MM_SPRITE_ANGRY

	# moth laugh
	if dialog.dialog_index == 6:
		moth_sprite_2d.texture = MM_SPRITE_LAUGH

	# crush flirty
	if dialog.dialog_index == 7:
		crush_sprite_2d.texture = BAE_SPRITE_GIGGLY

	# crush neutral
	if dialog.dialog_index == 8:
		crush_sprite_2d.texture = BAE_SPRITE_NEUTRAL

	# moth flustered
	if dialog.dialog_index == 9:
		moth_sprite_2d.texture = MM_SPRITE_FLUSTERED

	# moth laugh
	if dialog.dialog_index == 13:
		moth_sprite_2d.texture = MM_SPRITE_LAUGH

	# moth flustered
	if dialog.dialog_index == 14:
		moth_sprite_2d.texture = MM_SPRITE_FLUSTERED

	# moth sad
	if dialog.dialog_index == 16:
		moth_sprite_2d.texture = MM_SPRITE_SADGE

	# crush sad
	if dialog.dialog_index == 17:
		crush_sprite_2d.texture = BAE_SPRITE_SADGE

	# moth laugh
	if dialog.dialog_index == 18:
		moth_sprite_2d.texture = MM_SPRITE_LAUGH

	# cultist angry
	# cultist appears
	if dialog.dialog_index == 20:
		goon_sprite_2d.texture = GRUNT_SPRITE_ANGRY
		animation_player.play("goon_on")

	# crush angry
	if dialog.dialog_index == 21:
		crush_sprite_2d.texture = BAE_SPRITE_ANGRY

	# moth angry
	if dialog.dialog_index == 22:
		moth_sprite_2d.texture = MM_SPRITE_ANGRY

	# cultist laugh
	if dialog.dialog_index == 23:
		goon_sprite_2d.texture = GRUNT_SPRITE_EVILLAUGH

	# cultist neutral
	if dialog.dialog_index == 24:
		goon_sprite_2d.texture = GRUNT_SPRITE_NEUTRAL

	# cultist angry
	if dialog.dialog_index == 27:
		goon_sprite_2d.texture = GRUNT_SPRITE_ANGRY

	# moth neutral
	if dialog.dialog_index == 27:
		moth_sprite_2d.texture = MM_SPRITE_NEUTRAL

	# moth flustered
	# cultist disappears
	if dialog.dialog_index == 31:
		moth_sprite_2d.texture = MM_SPRITE_FLUSTERED
		animation_player.play("goon_off")

	# crush sad
	if dialog.dialog_index == 32:
		crush_sprite_2d.texture = BAE_SPRITE_SADGE

	# crush neutral
	if dialog.dialog_index == 34:
		crush_sprite_2d.texture = BAE_SPRITE_NEUTRAL

	# moth neutral
	if dialog.dialog_index == 35:
		moth_sprite_2d.texture = MM_SPRITE_NEUTRAL

	# crush sad
	if dialog.dialog_index == 36:
		crush_sprite_2d.texture = BAE_SPRITE_SADGE

	# moth sad
	if dialog.dialog_index == 37:
		moth_sprite_2d.texture = MM_SPRITE_SADGE

	# crush neutral
	if dialog.dialog_index == 40:
		crush_sprite_2d.texture = BAE_SPRITE_NEUTRAL

	# moth laugh
	if dialog.dialog_index == 42:
		moth_sprite_2d.texture = MM_SPRITE_LAUGH

	# change to game
	if dialog.dialog_index == 45:
		GameGlobals.audio_manager.fade_persistent_audio_out_and_destroy("music_good", 1)
		GameUi.ui_transitions.change_scene("res://game/title/menu.tscn")
