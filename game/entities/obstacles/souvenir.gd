class_name Souvenir
extends LaneEntity

const spawn_offset_from_anchor: float = 20
const movement_per_second: float = 150

@onready var meleehitboxarea: Area2D = $"PunchHitBoxArea"
@onready var punch_hit_box: CollisionShape2D = $PunchHitBoxArea/PunchHitBox
@onready var parryhitboxarea: Area2D = $"ParryHitBoxArea"
@onready var parry_hit_box: CollisionShape2D = $ParryHitBoxArea/ParryHitBox
@onready var collecthitboxarea: Area2D = $"CollectHitBoxArea"
@onready var collect_hix_box: CollisionShape2D = $CollectHitBoxArea/CollectHixBox
@onready var sprite_2d: Sprite2D = $SouvenirSprite

var assignedSprite: Resource

var super_meter_handler: SuperMeterHandler
var main_game_scene: MainGameScene

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
		
	
	global_position = Vector2(back_spawn_anchor.global_position.x, back_spawn_anchor.global_position.y)
	
	main_game_scene = get_tree().current_scene
	super_meter_handler = main_game_scene.super_meter_handler
	
	if assignedSprite:
		sprite_2d.texture = assignedSprite
		# Sprite pixels seem to be x2 as big as actual engine pixels, remind me to check with Myr to Learn How That Happen, 
		# assuming & hard-coding this scaling here is a bit of a spaghet solution
		var width: float = sprite_2d.texture.get_width() * 2
		var height: float = sprite_2d.texture.get_height() * 2
		
		punch_hit_box.shape = RectangleShape2D.new()
		parry_hit_box.shape = RectangleShape2D.new()
		collect_hix_box.shape = RectangleShape2D.new()
		punch_hit_box.shape.set_size(Vector2(width, height))
		parry_hit_box.shape.set_size(Vector2(width, height))
		collect_hix_box.shape.set_size(Vector2(width, height))
		
		#print("Souv of sprite " + str(assignedSprite.resource_path) + " is now " + str(punch_hit_box.shape.size))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	_ending_fade()
	global_position.x = global_position.x - (delta * movement_per_second)

func _on_window_size_changed() -> void:
	var viewport_length: float = get_viewport_rect().size.x
	var sprite_width: float = 70.0 # Assuming longest sprite, flower
	
	if position.x > (viewport_length - sprite_width):
		position.x = (viewport_length - sprite_width)
	return


func _on_punched() -> void:
	GameGlobals.audio_manager.create_audio("sound_punch")
	super_meter_handler.on_combo_break()
	if is_instance_valid(sprite_2d):
		sprite_2d.queue_free()
		GameUtils.spawn_explosion(get_tree().current_scene, global_position)
	_begin_despawn()
	
func _on_deflected() -> void:
	GameGlobals.audio_manager.create_audio("sound_deflect")
	if is_instance_valid(sprite_2d):
		sprite_2d.queue_free()
		GameUtils.spawn_explosion(get_tree().current_scene, global_position)
	_begin_despawn()
	
func _on_collected() -> void:
	GameGlobals.audio_manager.create_audio("sound_collect")
	
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
	var spawner: ObstacleSpawner = get_tree().current_scene.obstacle_spawner
	spawner.despawn_obstacle(current_lane, get_instance_id())
	
	queue_free()

func _ending_fade() -> void:
	if GameGlobals.game_dictionary["flag"].has("ending"):
		if GameGlobals.game_dictionary["flag"]["ending"]:
			var ending_tween: Tween = create_tween()
			ending_tween.finished.connect(_begin_despawn)
			ending_tween.tween_property(self,"modulate:a",0,1)
