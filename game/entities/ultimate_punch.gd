extends Node2D

@onready var punch: AnimatedSprite2D = $Punch
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var target: Node2D = null


func _ready() -> void:
	modulate.a = 0
	punch.animation_finished.connect(_on_punch_finished)
	animation_player.animation_finished.connect(_on_fade_finished)
	animation_player.play("fade_in")


func _on_punch_finished() -> void:
	if punch.animation == "punch_1":
		punch.play("punch_2")
	if punch.animation == "punch_2":
		GameGlobals.audio_manager.create_audio("sound_punch")
		animation_player.play("fade_out")
		if is_instance_valid(target):
			if "super_kill" in target:
				target.is_super_kill = true
				target.process_mode = Node.PROCESS_MODE_ALWAYS


func _on_fade_finished(anim_name: String) -> void:
	if anim_name == "fade_in":
		punch.play("punch_1")
	if anim_name == "fade_out":
		queue_free()
