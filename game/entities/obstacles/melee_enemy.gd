class_name MeleeEnemy
extends LaneEntity

var lane_id: Lanes.LaneId = Lanes.LaneId.MIDDLE



enum State { ARRIVING, IDLE, WINDUP, DEFEATED, ESCAPE }


const spawn_offset_from_anchor: float = 20
const movement_per_second: float = 300

@onready var hurtboxarea: Area2D = $"HurtBoxArea"
@onready var meleehitboxarea: Area2D = $"MeleeHitBoxArea"
@onready var parryhitboxarea: Area2D = $"ParryHitBoxArea"
@onready var sprite_2d: Node = $MeleeEnemySprite

var super_meter_handler: SuperMeterHandler
var main_game_scene: MainGameScene

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
	return


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	global_position.x = global_position.x - (delta * movement_per_second)
	return



func _on_punched() -> void:
	main_game_scene.apply_time_bonus(1)
	super_meter_handler.on_successful_punch()
	_on_defeated()
	## TODO animate
	
func _on_meteored() -> void:
	_on_defeated()
	
func _on_deflected() -> void:
	main_game_scene.apply_time_bonus(2)
	super_meter_handler.on_successful_deflect()
	_on_defeated()
	## TODO animate

func _on_defeated() -> void:
	if is_instance_valid(sprite_2d):
		sprite_2d.queue_free()
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
