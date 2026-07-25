extends Node2D

@onready var dialog: Dialog = $Dialog
@onready var moth_sprite_2d: Sprite2D = $MothSprite2D
@onready var crush_sprite_2d: Sprite2D = $CrushSprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	GameUi.ui_transitions.toggle_transition(false)
	await get_tree().create_timer(1).timeout
	dialog.dialog_changed.connect(_on_dialog_changed)
	dialog.active = true


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
		GameUi.ui_transitions.change_scene("res://game/main/main_game_scene.tscn")
