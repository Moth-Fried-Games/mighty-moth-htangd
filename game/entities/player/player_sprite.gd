class_name PlayerSprite
extends AnimatedSprite2D

@onready var aura_sprite: AnimatedSprite2D = $AuraSprite

var punching: bool = false


func _ready() -> void:
	aura_sprite.visible = false
	animation_finished.connect(_on_animation_finished)


func _process(_delta: float) -> void:
	if aura_sprite.frame != frame:
		aura_sprite.frame = frame
	if animation == "ultimate":
		if not aura_sprite.visible:
			aura_sprite.visible = true
	else:
		if aura_sprite.visible:
			aura_sprite.visible = false
	if animation == "punch" and frame == 1:
		if not punching:
			punching = true
	else:
		if punching:
			punching = false

func _on_animation_finished() -> void:
	if animation != "fly":
		play("fly")
	#if animation == "deflect":
	#	owner.hit_box.stop_deflect()
