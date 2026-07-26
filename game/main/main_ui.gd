@tool
extends CanvasLayer

@onready var super_bar: TextureProgressBar = %SuperBar
@onready var date_bar: TextureProgressBar = %DateBar
@onready var time_needle: TextureRect = %TimeNeedle
@onready var time_warning: TextureRect = %TimeWarning

@export_range(0, 3) var super_level: int = 0
@export_range(0, 100) var super_value: float = 0
@export_range(0, 100) var super_minimums: Array[float] = [23, 53, 76, 100]
@export_range(0, 100) var super_maximums: Array[float] = [52, 75, 100, 100]
@export_range(0, 10) var souvenirs: int = 0
@export_range(0, 100) var souvenir_minimum: float = 23
@export_range(0, 100) var souvenir_maximum: float = 100
@export_range(0, 60) var time_left: float = 60

var main_scene: Node2D = null
var super_scene: Node2D = null


func _process(_delta: float) -> void:
	_update_values()
	_update_super()
	_update_timer()
	_update_date()


func _update_values() -> void:
	if not Engine.is_editor_hint():
		if not is_instance_valid(main_scene):
			main_scene = get_parent()
		if not is_instance_valid(super_scene):
			super_scene = main_scene.super_meter_handler
		super_level = clampi(super_scene.super_level, 0, 3)
		super_value = clampf(super_scene.super_meter, 0, 100)
		time_left = clampf(main_scene.game_over_timer.time_left, 0, 60)
		souvenirs = clampi(main_scene.souvenirs_collected, 0, 10)


func _update_super() -> void:
	var super_interval: float = (
		(super_maximums[super_level] - super_minimums[super_level]) * (super_value * 0.01)
	)
	super_bar.value = clampf(
		super_minimums[super_level] + super_interval,
		super_minimums[super_level],
		super_maximums[super_level]
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
