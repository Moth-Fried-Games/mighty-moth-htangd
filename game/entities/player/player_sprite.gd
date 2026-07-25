extends AnimatedSprite2D

@onready var aura_sprite: AnimatedSprite2D = $AuraSprite


func _ready() -> void:
	aura_sprite.visible = false


func _process(_delta: float) -> void:
	aura_sprite.frame = frame
	if animation == "ultimate":
		aura_sprite.visible = true
	else:
		aura_sprite.visible = false
