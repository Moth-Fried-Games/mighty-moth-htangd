class_name Souvenir
extends LaneEntity

const spawn_offset_from_anchor: float = 20
const movement_per_second: float = 150

@onready var meleehitboxarea: Area2D = $"PunchHitBoxArea"
@onready var parryhitboxarea: Area2D = $"ParryHitBoxArea"
@onready var collecthitboxarea: Area2D = $"CollectHitBoxArea"
@onready var sprite_2d: Sprite2D = $SouvenirSprite

var assignedSprite: Resource

var super_meter_handler: SuperMeterHandler
var main_game_scene: MainGameScene

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
		
	
	global_position = Vector2(back_spawn_anchor.global_position.x, back_spawn_anchor.global_position.y)
	
	main_game_scene = get_tree().current_scene
	super_meter_handler = main_game_scene.super_meter_handler
	
	if assignedSprite:
		sprite_2d.texture = assignedSprite


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	global_position.x = global_position.x - (delta * movement_per_second)




func _on_punched() -> void:
	GameGlobals.audio_manager.create_audio("sound_punch")
	super_meter_handler.on_combo_break()
	if is_instance_valid(sprite_2d):
		sprite_2d.queue_free()
		GameUtils.spawn_explosion(get_tree().current_scene, global_position)
	## TODO ANIMATION FOR NOOOOOOOO DON'T PUNCH THE PREZZIE
	_begin_despawn()
	
func _on_deflected() -> void:
	GameGlobals.audio_manager.create_audio("sound_deflect")
	if is_instance_valid(sprite_2d):
		sprite_2d.queue_free()
		GameUtils.spawn_explosion(get_tree().current_scene, global_position)
	## TODO ANIMATION FOR  NOOOO DON'T PARRY THE PREZZIE
	_begin_despawn()
	
func _on_collected() -> void:
	GameGlobals.audio_manager.create_audio("sound_collect")
	
	## TODO YIPPIEEEE YOU GOT IT!!! but todo animate it
	if is_instance_valid(sprite_2d):
		sprite_2d.queue_free()
		GameUtils.spawn_sparkle(get_tree().current_scene, global_position)
	main_game_scene.souvenirs_collected += 1
	super_meter_handler.on_successful_collect()
	_begin_despawn()

func _on_walk_past_player() -> void:
	_begin_despawn()
	pass

func _begin_despawn() -> void:
	collecthitboxarea.queue_free()
	meleehitboxarea.queue_free()
	parryhitboxarea.queue_free()
	
	var spawner: ObstacleSpawner = get_tree().current_scene.obstacle_spawner
	spawner.despawn_obstacle(current_lane, get_instance_id())
	
	var despawn_timer: Timer = Timer.new()
	despawn_timer.wait_time = 4
	despawn_timer.one_shot = true
	despawn_timer.timeout.connect(func() -> void: free())
