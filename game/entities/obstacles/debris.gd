class_name Debris
extends LaneEntity

const spawn_offset_from_anchor: float = 50
const movement_per_second: float = 1700
var is_moving: bool = false
var is_deflected: bool = false

var warning_timer: Timer
var despawn_timer: Timer = Timer.new()

@onready var hurtboxarea: Area2D = $"HurtBoxArea"
@onready var meleehitboxarea: Area2D = $"PunchHitBoxArea"
@onready var parryhitboxarea: Area2D = $"ParryHitBoxArea"
@onready var debris_warning: Node2D = $DebrisWarning
@onready var warning_label: Label = $DebrisWarning/WarningLabel
@onready var distance_countdown: Label = $DebrisWarning/DistanceCountdown
@onready var sprite_2d: Node = $Sprite2D

var super_meter_handler: SuperMeterHandler
var main_game_scene: MainGameScene

var incoming_distance_display: int:
	get():
		if warning_timer != null and !warning_timer.is_stopped():
			return roundi(warning_timer.time_left * 100)
		return 0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var lane_binder: Lanes = get_tree().current_scene.lane_binders
	
	var back_spawn_anchor: Marker2D = null
	match current_lane:
		Lanes.LaneId.TOP:
			back_spawn_anchor = lane_binder.top_right_anchor
		Lanes.LaneId.MIDDLE:
			back_spawn_anchor = lane_binder.middle_right_anchor
		Lanes.LaneId.BOTTOM:
			back_spawn_anchor = lane_binder.bottom_right_anchor
	
	global_position = Vector2(back_spawn_anchor.global_position.x + spawn_offset_from_anchor, back_spawn_anchor.global_position.y)
	debris_warning.global_position.x = get_viewport_rect().size.x - 80
	
	main_game_scene = get_tree().current_scene
	super_meter_handler = main_game_scene.super_meter_handler
	
	var rando: RandomNumberGenerator = RandomNumberGenerator.new()
	warning_timer = Timer.new()
	warning_timer.wait_time = rando.randi() % 5 + 5
	warning_timer.one_shot = true
	warning_timer.timeout.connect(func() -> void: 
		debris_warning.queue_free()
		is_moving = true
		GameGlobals.audio_manager.create_audio("sound_meteor_approach")
	)
	add_child(warning_timer)
	warning_timer.start()
	
	GameGlobals.audio_manager.create_audio("sound_meteor_alert")
	
	return


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if is_moving:
		var movement: float = (delta * movement_per_second)
		if is_deflected:
			movement *= -1
		global_position.x = global_position.x - movement
		return
	else:
		distance_countdown.text = str(_get_distance_display()) + " m"
		
	## TODO update warning display
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
	main_game_scene.apply_time_bonus(1)
	super_meter_handler.on_successful_punch()
	_on_destroyed()
	## TODO animate, confirm interaction
	
func _on_deflected() -> void:
	GameGlobals.audio_manager.create_audio("sound_deflect")
	main_game_scene.apply_time_bonus(2)
	super_meter_handler.on_successful_deflect()
	
	is_deflected = true
	sprite_2d.flip_h = true
	
	despawn_timer.wait_time = 2.0
	despawn_timer.one_shot = true
	despawn_timer.timeout.connect(func() -> void: _begin_despawn() )
	add_child(despawn_timer)
	despawn_timer.start()
	
	hurtboxarea.collision_layer = 0
	meleehitboxarea.collision_layer = 0
	parryhitboxarea.collision_layer = 0
	hurtboxarea.collision_mask = 6 ## Can now hit melee enemies and ranged enemies
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
	if is_instance_valid(sprite_2d):
		sprite_2d.queue_free()
	_begin_despawn()
	## TODO defeat animation
	return
	
func _on_touching_player() -> void:
	super_meter_handler.on_combo_break()
	_begin_despawn()
	### TODO animate and annoy mightymoth a little
	return

# When this goes off the edge of the screen
func _on_walk_past_player() -> void:
	super_meter_handler.on_combo_break()
	_begin_despawn()
	return

# Finally, begin to despawn, free resources, and inform the obstacle spawner that this can spawn in the same lane again
func _begin_despawn() -> void:
	if is_instance_valid(self):
		hurtboxarea.queue_free()
		meleehitboxarea.queue_free()
		parryhitboxarea.queue_free()
		
		var spawner: ObstacleSpawner = get_tree().current_scene.obstacle_spawner
		spawner.despawn_obstacle(current_lane, get_instance_id())
		
		#var despawn_timer: Timer = Timer.new()
		despawn_timer.wait_time = 4
		despawn_timer.one_shot = true
		despawn_timer.timeout.connect(func() -> void: free())
