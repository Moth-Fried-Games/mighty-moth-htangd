class_name EnemyProjectile
extends LaneEntity

var lane_id: Lanes.LaneId = Lanes.LaneId.MIDDLE



enum State { ARRIVING, IDLE, WINDUP, DEFEATED, ESCAPE }


const spawn_offset_from_anchor: float = 20
var movement_per_second: float = 300

@onready var enemy_projectile_sprite: AnimatedSprite2D = $RangeEnemyProjectileSprite
@onready var hurtboxarea: Area2D = $"HurtBoxArea"
@onready var parryhitboxarea: Area2D = $"ParryHitBoxArea"
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
	
	area_entered.connect(_on_area_entered)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	global_position.x = global_position.x - (delta * movement_per_second)


func _on_deflected() -> void:
	print("oh wow I am deflecteded")
	enemy_projectile_sprite.flip_h = true
	monitoring = true
	movement_per_second *= -1
	main_game_scene.apply_time_bonus(2)
	super_meter_handler.on_successful_deflect()

func _on_touching_player() -> void:
	super_meter_handler.on_combo_break()
	_begin_despawn()
	## TODO animate and annoy mightymoth a little

func _on_walk_past_player() -> void:
	super_meter_handler.on_combo_break()
	_begin_despawn()

func _begin_despawn() -> void:
	hurtboxarea.queue_free()
	parryhitboxarea.queue_free()
	
	var spawner: ObstacleSpawner = get_tree().current_scene.obstacle_spawner
	spawner.despawn_obstacle(lane_id, get_instance_id())
	
	var despawn_timer: Timer = Timer.new()
	despawn_timer.wait_time = 4
	despawn_timer.one_shot = true
	despawn_timer.timeout.connect(func() -> void: free())

func _on_area_entered(area: Area2D) -> void:
	area.queue_free()
 
