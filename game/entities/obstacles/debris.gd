class_name Debris
extends LaneEntity

var lane_id: Lanes.LaneId = Lanes.LaneId.MIDDLE

const spawn_offset_from_anchor: float = 20
const movement_per_second: float = 4333
var is_moving: bool = false

var warning_timer: Timer

@onready var hurtboxarea: Area2D = $"HurtBoxArea"
@onready var meleehitboxarea: Area2D = $"PunchHitBoxArea"
@onready var parryhitboxarea: Area2D = $"ParryHitBoxArea"
@onready var debris_warning: Node2D = $DebrisWarning
@onready var warning_label: Label = $DebrisWarning/WarningLabel
@onready var distance_countdown: Label = $DebrisWarning/DistanceCountdown

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
	match lane_id:
		Lanes.LaneId.TOP:
			back_spawn_anchor = lane_binder.top_right_anchor
		Lanes.LaneId.MIDDLE:
			back_spawn_anchor = lane_binder.middle_right_anchor
		Lanes.LaneId.BOTTOM:
			back_spawn_anchor = lane_binder.bottom_right_anchor
	
	global_position = Vector2(back_spawn_anchor.global_position.x, back_spawn_anchor.global_position.y)
	
	main_game_scene = get_tree().current_scene
	super_meter_handler = main_game_scene.super_meter_handler
	
	var rando = RandomNumberGenerator.new()
	warning_timer = Timer.new()
	warning_timer.wait_time = rando.randi() % 5 + 15 # TODO set to % 5 + 5
	warning_timer.one_shot = true
	warning_timer.timeout.connect(func() -> void: 
		debris_warning.queue_free()
		## TODO hide warning!!!
		is_moving = true
	)
	add_child(warning_timer)
	warning_timer.start()
	return


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if is_moving:
		global_position.x = global_position.x - (delta * movement_per_second)
		return
	else:
		distance_countdown.text = str(_get_distance_display()) + " m"
		
	## TODO update warning display
	return


func _get_distance_display() -> float:
	return roundf(warning_timer.time_left * 100.0)


func _on_punched() -> void:
	main_game_scene.apply_time_bonus(1)
	super_meter_handler.on_successful_punch()
	_on_destroyed()
	## TODO animate, confirm interaction
	
func _on_deflected() -> void:
	#main_game_scene.apply_time_bonus(2)
	super_meter_handler.on_successful_deflect()
	## TODO add logic to make this thing damage and defeat an enemy when deflected. Do not run _on_destroyed until AFTER this defeats something, or otherwise leaves the right side of the screen!

func _on_destroyed() -> void:
	_begin_despawn()
	## TODO defeat animation
	pass
	
func _on_touching_player() -> void:
	super_meter_handler.on_combo_break()
	_begin_despawn()
	## TODO animate and annoy mightymoth a little
	pass

func _on_walk_past_player() -> void:
	super_meter_handler.on_combo_break()
	_begin_despawn()
	pass

func _begin_despawn() -> void:
	hurtboxarea.queue_free()
	meleehitboxarea.queue_free()
	parryhitboxarea.queue_free()
	
	var spawner: ObstacleSpawner = get_tree().current_scene.obstacle_spawner
	spawner.despawn_obstacle(lane_id, get_instance_id())
	
	var despawn_timer: Timer = Timer.new()
	despawn_timer.wait_time = 4
	despawn_timer.one_shot = true
	despawn_timer.timeout.connect(func() -> void: free())
