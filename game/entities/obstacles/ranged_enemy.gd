class_name RangedEnemy
extends LaneEntity

const RANGE_ENEMY_PROJECTILE = preload("uid://dkpcrcnigdbei")

enum State { ARRIVING, IDLE, WINDUP, DEFEATED, ESCAPE }

const spawn_offset_from_anchor: float = 140
const movement_per_second: float = 300
const arrival_move_speed: float = 100

var is_super_kill: bool = false
var is_super_defeat: bool = false
var is_defeat: bool = false
var ending_point: float = 0
var is_shooting: bool = false

@onready var ranged_enemy_sprite: RangeEnemySprite = $RangedEnemySprite

var super_meter_handler: SuperMeterHandler
var main_game_scene: MainGameScene

#signal rocket_fired


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

	global_position = Vector2(
		back_spawn_anchor.global_position.x + spawn_offset_from_anchor,
		back_spawn_anchor.global_position.y
	)

	main_game_scene = get_tree().current_scene
	super_meter_handler = main_game_scene.super_meter_handler
	add_to_group("ultimate")
	return


func _process(delta: float) -> void:
	_adjust_enemy(delta)
	_ending_fade()
	if is_super_kill:
		if not is_super_defeat:
			super_kill()


func _adjust_enemy(delta: float) -> void:
	var lane_binder: Lanes = get_tree().current_scene.lane_binders
	var back_spawn_anchor: Marker2D = null
	match current_lane:
		Lanes.LaneId.TOP:
			back_spawn_anchor = lane_binder.top_right_anchor
		Lanes.LaneId.MIDDLE:
			back_spawn_anchor = lane_binder.middle_right_anchor
		Lanes.LaneId.BOTTOM:
			back_spawn_anchor = lane_binder.bottom_right_anchor

	if ending_point != (back_spawn_anchor.global_position.x - spawn_offset_from_anchor):
		ending_point = (back_spawn_anchor.global_position.x - spawn_offset_from_anchor)

	if global_position.x > ending_point:
		global_position.x = global_position.x - (delta * movement_per_second)
	else:
		if not is_shooting:
			is_shooting = true
			_spawn_projectile()
		if global_position.x != ending_point:
			global_position.x = ending_point
	return


func _on_meteored() -> void:
	GameGlobals.audio_manager.create_audio("sound_explosion")
	_on_defeated()


func _on_missle_countered() -> void:
	#main_game_scene.apply_time_bonus(0.2)
	super_meter_handler.on_successful_deflect()
	GameGlobals.audio_manager.create_audio("sound_explosion")
	_on_defeated()


func _on_defeated() -> void:
	is_defeat = true
	if is_instance_valid(ranged_enemy_sprite):
		ranged_enemy_sprite.queue_free()
		GameUtils.spawn_explosion(get_tree().current_scene, global_position)
	_begin_despawn()
	pass


func _on_walk_past_player() -> void:
	_begin_despawn()
	pass


func _begin_despawn() -> void:
	var spawner: ObstacleSpawner = get_tree().current_scene.obstacle_spawner
	spawner.despawn_obstacle(current_lane, get_instance_id())

	queue_free()


func _spawn_projectile() -> void:
	if is_instance_valid(ranged_enemy_sprite):
		ranged_enemy_sprite.play("shoot")


func _on_ranged_enemy_sprite_rocket_fired() -> void:
	var new_projectile: EnemyProjectile = RANGE_ENEMY_PROJECTILE.instantiate()
	new_projectile.current_lane = current_lane
	new_projectile.global_position = global_position
	new_projectile.enemy_that_shoot = self
	get_tree().current_scene.call_deferred("add_child", new_projectile)
	return


func super_kill() -> void:
	is_super_defeat = true
	super_meter_handler.increment_combo(super_meter_handler.combo_increment_on_punch)
	main_game_scene.apply_time_bonus(1 * super_meter_handler.super_level)
	_on_defeated()


func _ending_fade() -> void:
	if GameGlobals.game_dictionary["flag"].has("ending"):
		if GameGlobals.game_dictionary["flag"]["ending"]:
			var ending_tween: Tween = create_tween()
			ending_tween.finished.connect(_begin_despawn)
			ending_tween.tween_property(self, "modulate:a", 0, 1)
