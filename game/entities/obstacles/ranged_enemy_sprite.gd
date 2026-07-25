extends AnimatedSprite2D

@onready var fire_sprite: Sprite2D = $FireSprite

signal rocket_fired


func _process(_delta: float) -> void:
	if animation == "shoot" and frame == 1:
		if not fire_sprite.visible:
			fire_sprite.visible = true
			rocket_fired.emit()
	else:
		if fire_sprite.visible:
			fire_sprite.visible = false
