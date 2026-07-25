extends AnimatedSprite2D

@onready var aura_sprite: AnimatedSprite2D = $AuraSprite


func _ready() -> void:
	aura_sprite.visible = false


func _process(_delta: float) -> void:
	if aura_sprite.frame != frame:
		aura_sprite.frame = frame
	if animation == "ultimate":
		if not aura_sprite.visible:
			aura_sprite.visible = true
	else:
		if aura_sprite.visible:
			aura_sprite.visible = false
