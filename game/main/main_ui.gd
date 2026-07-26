@tool
extends CanvasLayer

@onready var super_bar: TextureProgressBar = %SuperBar
@onready var date_bar: TextureProgressBar = %DateBar
@onready var time_needle: TextureRect = %TimeNeedle
@onready var time_warning: TextureRect = %TimeWarning

@export_range(1, 3) var super_level: int = 1
@export_range(0, 100) var super_value: float = 0
@export_range(0, 100) var super_minimums: Array[float] = [23, 53, 76]
@export_range(0, 100) var super_maximums: Array[float] = [52, 75, 100]
@export_range(0, 10) var souvenirs: int = 0
@export_range(0, 100) var souvenir_minimum: float = 23
@export_range(0, 100) var souvenir_maximum: float = 100
@export_range(0, 60) var time_left: float = 60


func _process(_delta: float) -> void:
	_update_super()
	_update_timer()
	_update_date()


func _update_super() -> void:
	var super_interval: float = (
		(super_maximums[super_level - 1] - super_minimums[super_level - 1]) * (super_value * 0.01)
	)
	super_bar.value = clampf(
		super_minimums[super_level - 1] + super_interval,
		super_minimums[super_level - 1],
		super_maximums[super_level - 1]
	)


func _update_timer() -> void:
	var time_percent: float = 1 - (time_left / 60)
	time_needle.rotation_degrees = wrapf(time_percent * 360, 0, 360)
	if time_left <= 14:
		if not time_warning.visible:
			time_warning.visible = true
	else:
		if time_warning.visible:
			time_warning.visible = false


func _update_date() -> void:
	var souvenir_percent: float = souvenirs * 0.1
	var souvenir_interval: float = (souvenir_maximum - souvenir_minimum) * souvenir_percent
	date_bar.value = clampf(
		souvenir_minimum + souvenir_interval, souvenir_minimum, souvenir_maximum
	)
