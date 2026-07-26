class_name Souvenir
extends LaneEntity

var lane_id: Lanes.LaneId = Lanes.LaneId.MIDDLE

const spawn_offset_from_anchor: float = 20
const movement_per_second: float = 150

@onready var meleehitboxarea: Area2D = $"PunchHitBoxArea"
@onready var parryhitboxarea: Area2D = $"ParryHitBoxArea"
@onready var collecthitboxarea: Area2D = $"CollectHitBoxArea"
@onready var sprite_2d: Sprite2D = $SouvenirSprite

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


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	global_position.x = global_position.x - (delta * movement_per_second)




func _on_punched() -> void:
	print("Souvenir PUNCHED")
	super_meter_handler.on_combo_break()
	if is_instance_valid(sprite_2d):
		sprite_2d.queue_free()
	## TODO ANIMATION FOR NOOOOOOOO DON'T PUNCH THE PREZZIE
	_begin_despawn()
	
func _on_deflected() -> void:
	print("Souvenir DEFLECTED")
	super_meter_handler.on_combo_break()
	if is_instance_valid(sprite_2d):
		sprite_2d.queue_free()
	## TODO ANIMATION FOR  NOOOO DON'T PARRY THE PREZZIE
	_begin_despawn()
	
func _on_collected() -> void:
	print("Souvenir COLLECTED")
	## TODO YIPPIEEEE YOU GOT IT!!! but todo animate it
	if is_instance_valid(sprite_2d):
		sprite_2d.queue_free()
	main_game_scene.souvenirs_collected += 1
	super_meter_handler.on_successful_collect()
	_begin_despawn()

func _on_walk_past_player() -> void:
	super_meter_handler.on_combo_break()
	_begin_despawn()
	pass

func _begin_despawn() -> void:
	collecthitboxarea.queue_free()
	meleehitboxarea.queue_free()
	parryhitboxarea.queue_free()
	
	var spawner: ObstacleSpawner = get_tree().current_scene.obstacle_spawner
	spawner.despawn_obstacle(lane_id, get_instance_id())
	
	var despawn_timer: Timer = Timer.new()
	despawn_timer.wait_time = 4
	despawn_timer.one_shot = true
	despawn_timer.timeout.connect(func() -> void: free())
