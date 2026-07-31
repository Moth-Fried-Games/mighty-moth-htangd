class_name EnemyProjectile
extends LaneEntity

enum State { ARRIVING, IDLE, WINDUP, DEFEATED, ESCAPE }

const spawn_offset_from_anchor: float = 200
var movement_per_second: float = 300
var is_deflected: bool = false
var is_super_kill: bool = false
var is_super_defeat: bool = false
var is_defeat: bool = false
var despawn_timer: Timer = Timer.new()

@onready var enemy_projectile_sprite: AnimatedSprite2D = $RangeEnemyProjectileSprite
@onready var hurtboxarea: Area2D = $"HurtBoxArea"
@onready var parryhitboxarea: Area2D = $"ParryHitBoxArea"

var enemy_that_shoot: RangedEnemy
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

	global_position = Vector2(
		back_spawn_anchor.global_position.x - spawn_offset_from_anchor,
		back_spawn_anchor.global_position.y
	)

	main_game_scene = get_tree().current_scene
	super_meter_handler = main_game_scene.super_meter_handler

	area_entered.connect(_on_area_entered)
	add_to_group("ultimate")


func _process(_delta: float) -> void:
	if is_super_kill:
		if not is_super_defeat:
			super_kill()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	global_position.x = global_position.x - (delta * movement_per_second)


func _on_window_size_changed() -> void:
	var viewport_length: float = get_viewport_rect().size.x
	var sprite_width: float = 80.0

	if position.x > (viewport_length - sprite_width):
		position.x = (viewport_length - sprite_width)
	return


func _is_in_same_lane(colliding_area: Area2D) -> bool:
	if colliding_area is RangedEnemy:
		return colliding_area.current_lane == current_lane
	return false


func _on_deflected() -> void:
	GameGlobals.audio_manager.create_audio("sound_deflect")

	is_deflected = true
	enemy_projectile_sprite.flip_h = true
	movement_per_second *= -3

	despawn_timer.wait_time = 12
	despawn_timer.one_shot = true
	despawn_timer.timeout.connect(func() -> void: _begin_despawn())
	add_child(despawn_timer)
	despawn_timer.start()

	hurtboxarea.collision_layer = 0
	parryhitboxarea.collision_layer = 0
	hurtboxarea.collision_mask = 4  ## Can now hit ranged enemies
	hurtboxarea.area_entered.connect(_on_deflected_area_entered)


func _on_deflected_area_entered(area: Area2D) -> void:
	if area == enemy_that_shoot and _is_in_same_lane(area):
		despawn_timer.stop()
		area._on_missle_countered()
		_on_destroyed()
	return


func _on_destroyed() -> void:
	is_defeat = true
	if is_instance_valid(enemy_projectile_sprite):
		enemy_projectile_sprite.queue_free()
		GameUtils.spawn_explosion(get_tree().current_scene, global_position)
	_begin_despawn()
	## TODO defeat animation
	return


func _on_touching_player() -> void:
	get_tree().current_scene.player._on_hit_reaction()
	_begin_despawn()
	return
	## TODO animate and annoy mightymoth a little


func _on_walk_past_player() -> void:
	_begin_despawn()


func _begin_despawn() -> void:
	if is_instance_valid(self):
		#if is_instance_valid(hurtboxarea):
			#hurtboxarea.queue_free()
		#if is_instance_valid(parryhitboxarea):
			#parryhitboxarea.queue_free()
		if !is_deflected:
			enemy_that_shoot._spawn_projectile()

		var spawner: ObstacleSpawner = get_tree().current_scene.obstacle_spawner
		spawner.despawn_obstacle(current_lane, get_instance_id())
		
		queue_free()

		#despawn_timer.wait_time = 4
		#despawn_timer.one_shot = true
		#despawn_timer.timeout.connect(func() -> void: queue_free())


func _on_area_entered(area: Area2D) -> void:
	if area == enemy_that_shoot:
		area._spawn_projectile()


func super_kill() -> void:
	is_super_defeat = true
	main_game_scene.apply_time_bonus(1 * super_meter_handler.super_level)
	_on_destroyed()
