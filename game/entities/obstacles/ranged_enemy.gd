class_name RangedEnemy
extends LaneEntity

const RANGE_ENEMY_PROJECTILE = preload("uid://dkpcrcnigdbei")

enum State { ARRIVING, IDLE, WINDUP, DEFEATED, ESCAPE }


const spawn_offset_from_anchor: float = 20
const movement_per_second: float = 300
const arrival_move_speed: float = 100

#@onready var hurtboxarea: Area2D = $"HurtBoxArea"
#@onready var meleehitboxarea: Area2D = $"MeleeHitBoxArea"
#@onready var parryhitboxarea: Area2D = $"ParryHitBoxArea"
@onready var ranged_enemy_sprite: RangeEnemySprite = $RangedEnemySprite
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
		
	
	global_position = Vector2(back_spawn_anchor.global_position.x - 50, back_spawn_anchor.global_position.y)
	
	main_game_scene = get_tree().current_scene
	super_meter_handler = main_game_scene.super_meter_handler
	_spawn_projectile()
	return


func process() -> void:
	return


#func _on_punched() -> void:
	#print("owie I am puncheded")
	#main_game_scene.apply_time_bonus(1)
	#super_meter_handler.on_successful_punch()
	#_on_defeated()
	### TODO animate
	
func _on_meteored() -> void:
	print("ouch I hate rocks")
	GameGlobals.audio_manager.create_audio("sound_explosion")
	_on_defeated()
	
func _on_missle_countered() -> void:
	print("NOOOOO I'M GETTING EXPLODED")
	GameGlobals.audio_manager.create_audio("sound_explosion")
	_on_defeated()
	
#func _on_deflected() -> void:
	#print("oh wow I am deflecteded")
	#main_game_scene.apply_time_bonus(2)
	#super_meter_handler.on_successful_deflect()
	#_on_defeated()
	### TODO animate

func _on_defeated() -> void:
	print("and thus I am deadddd")
	if is_instance_valid(ranged_enemy_sprite):
		ranged_enemy_sprite.queue_free()
	_begin_despawn()
	## TODO defeat animation
	pass
	
#func _on_touching_player() -> void:
	#super_meter_handler.on_combo_break()
	#_begin_despawn()
	### TODO animate and annoy mightymoth a little
	#pass

func _on_walk_past_player() -> void:
	super_meter_handler.on_combo_break()
	_begin_despawn()
	pass

func _begin_despawn() -> void:
	$"CollisionShape2D".queue_free()
	
	#hurtboxarea.queue_free()
	#meleehitboxarea.queue_free()
	#parryhitboxarea.queue_free()
	
	var spawner: ObstacleSpawner = get_tree().current_scene.obstacle_spawner
	spawner.despawn_obstacle(current_lane, get_instance_id())
	
	var despawn_timer: Timer = Timer.new()
	despawn_timer.wait_time = 4
	despawn_timer.one_shot = true
	despawn_timer.timeout.connect(func() -> void: free())

func _spawn_projectile() -> void:
	var new_projectile: EnemyProjectile = RANGE_ENEMY_PROJECTILE.instantiate()
	new_projectile.current_lane = current_lane
	new_projectile.global_position = global_position
	new_projectile.enemy_that_shoot = self
	add_child(new_projectile) ## Cannot call method 'add_child' on a null value.
	# _spawn_projectile(): Can't change this state while flushing queries. Use call_deferred() or set_deferred() to change monitoring state instead.
