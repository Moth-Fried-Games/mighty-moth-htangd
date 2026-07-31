class_name Debris
extends LaneEntity

const spawn_offset_from_anchor: float = 50
const movement_per_second: float = 1700
var is_moving: bool = false
var is_deflected: bool = false
var is_super_kill: bool = false
var is_super_defeat: bool = false
var is_defeat: bool = false

var warning_timer: Timer
var despawn_timer: Timer = Timer.new()

@onready var hurtboxarea: Area2D = $"HurtBoxArea"
@onready var meleehitboxarea: Area2D = $"PunchHitBoxArea"
@onready var parryhitboxarea: Area2D = $"ParryHitBoxArea"
@onready var debris_warning: Node2D = $DebrisWarning
@onready var distance_countdown: Label = $DebrisWarning/DistanceCountdown
@onready var sprite_2d: AnimatedSprite2D = $MeteorSprite

var super_meter_handler: SuperMeterHandler
var main_game_scene: MainGameScene

var incoming_distance_display: int:
	get():
		if warning_timer != null and !warning_timer.is_stopped():
			return roundi(warning_timer.time_left * 100)
		return 0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_tree().root.size_changed.connect(_on_window_size_changed)

	var lane_binder: Lanes = get_tree().current_scene.lane_binders

	var back_spawn_anchor: Marker2D = null
	match current_lane:
		Lanes.LaneId.TOP:
			back_spawn_anchor = lane_binder.top_right_anchor
		Lanes.LaneId.MIDDLE:
			back_spawn_anchor = lane_binder.middle_right_anchor
		Lanes.LaneId.BOTTOM:
			back_spawn_anchor = lane_binder.bottom_right_anchor

	global_position = Vector2(
		back_spawn_anchor.global_position.x + spawn_offset_from_anchor,
		back_spawn_anchor.global_position.y
	)

	var viewport_length: float = get_viewport_rect().size.x
	var meteor_width: float = 257.0  ## Measuring meteor's width by hand
	if position.x != (viewport_length + meteor_width):
		position.x = (viewport_length + meteor_width)

	var warning_distance: float = 50.0  # Measuring warning's distance by hand
	debris_warning.global_position.x = get_viewport_rect().size.x - warning_distance

	main_game_scene = get_tree().current_scene
	super_meter_handler = main_game_scene.super_meter_handler

	var rando: RandomNumberGenerator = RandomNumberGenerator.new()
	warning_timer = Timer.new()
	warning_timer.wait_time = rando.randi() % 5 + 5
	warning_timer.one_shot = true
	warning_timer.timeout.connect(
		func() -> void:
			if is_instance_valid(debris_warning):
				debris_warning.queue_free()
			is_moving = true
			GameGlobals.audio_manager.create_audio("sound_meteor_approach")
	)
	add_child(warning_timer)
	warning_timer.start()

	GameGlobals.audio_manager.create_audio("sound_meteor_alert")
	add_to_group("ultimate")
	return


func _process(_delta: float) -> void:
	if is_super_kill:
		if not is_super_defeat:
			super_kill()
	if not is_moving:
		if is_instance_valid(distance_countdown):
			distance_countdown.text = str(_get_distance_display()) + " m"


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if is_moving:
		var movement: float = delta * movement_per_second
		if is_deflected:
			movement *= -1
		global_position.x = global_position.x - movement
		return
	return


func _on_window_size_changed() -> void:
	var viewport_length: float = get_viewport_rect().size.x
	var meteor_width: float = 257.0  ## Measuring meteor's width by hand
	if !warning_timer.is_stopped():
		if position.x != (viewport_length + meteor_width):
			position.x = (viewport_length + meteor_width)

		var warning_distance: float = 50.0  # Measuring warning's distance by hand
		debris_warning.global_position.x = get_viewport_rect().size.x - warning_distance

	elif position.x > (viewport_length + meteor_width):
		position.x = (viewport_length + meteor_width)
	return


func _get_distance_display() -> float:
	return roundf(warning_timer.time_left * 100.0)


func _is_in_same_lane(colliding_area: Area2D) -> bool:
	if colliding_area is RangedEnemy:
		return colliding_area.current_lane == current_lane
	elif colliding_area.owner is LaneEntity:
		return colliding_area.owner.current_lane == current_lane
	return false


func _on_punched() -> void:
	GameGlobals.audio_manager.create_audio("sound_punch")
	main_game_scene.apply_time_bonus(0.1)
	super_meter_handler.on_successful_punch()
	_on_destroyed()


func _on_deflected() -> void:
	GameGlobals.audio_manager.create_audio("sound_deflect")
	main_game_scene.apply_time_bonus(0.2)
	super_meter_handler.on_successful_deflect()

	is_deflected = true
	sprite_2d.flip_h = true

	despawn_timer.wait_time = 12.0
	despawn_timer.one_shot = true
	despawn_timer.timeout.connect(func() -> void: _begin_despawn())
	add_child(despawn_timer)
	despawn_timer.start()

	hurtboxarea.collision_layer = 0
	meleehitboxarea.collision_layer = 0
	parryhitboxarea.collision_layer = 0
	hurtboxarea.collision_mask = 6  ## Can now hit melee enemies and ranged enemies
	hurtboxarea.area_entered.connect(_on_deflected_area_entered)


# After this has been deflected, and is colliding with something, determine if it should destroy both this and the collliding entity
func _on_deflected_area_entered(area: Area2D) -> void:
	if _is_in_same_lane(area) and area.is_in_group("MeleeHitBoxArea"):
		if area is RangedEnemy:
			despawn_timer.stop()
			area._on_meteored()
			_on_destroyed()
		if area.owner is MeleeEnemy:
			despawn_timer.stop()
			area.owner._on_meteored()
			_on_destroyed()
	return


func _on_destroyed() -> void:
	is_defeat = true
	if is_instance_valid(debris_warning):
		debris_warning.queue_free()
	if is_instance_valid(sprite_2d):
		sprite_2d.queue_free()
		GameUtils.spawn_explosion(get_tree().current_scene, global_position)
	_begin_despawn()
	return


func _on_touching_player() -> void:
	get_tree().current_scene.player._on_hit_reaction()
	_begin_despawn()
	return


# When this goes off the edge of the screen
func _on_walk_past_player() -> void:
	_begin_despawn()
	return


# Finally, begin to despawn, free resources, and inform the obstacle spawner that this can spawn in the same lane again
func _begin_despawn() -> void:
	if is_instance_valid(self):
		var spawner: ObstacleSpawner = get_tree().current_scene.obstacle_spawner
		spawner.despawn_obstacle(current_lane, get_instance_id())
		
		queue_free()


func super_kill() -> void:
	is_super_defeat = true
	main_game_scene.apply_time_bonus(1 * super_meter_handler.super_level)
	_on_destroyed()
