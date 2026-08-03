class_name MeleeEnemy
extends LaneEntity

enum State { ARRIVING, IDLE, WINDUP, DEFEATED, ESCAPE }

const spawn_offset_from_anchor: float = 20
const movement_per_second: float = 300

@onready var hurtboxarea: Area2D = $"HurtBoxArea"
@onready var meleehitboxarea: Area2D = $"MeleeHitBoxArea"
@onready var parryhitboxarea: Area2D = $"ParryHitBoxArea"
@onready var sprite_2d: Node = $MeleeEnemySprite

var is_super_kill: bool = false
var is_super_defeat: bool = false
var is_defeat: bool = false

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
		back_spawn_anchor.global_position.x, back_spawn_anchor.global_position.y
	)

	main_game_scene = get_tree().current_scene
	super_meter_handler = main_game_scene.super_meter_handler
	add_to_group("ultimate")
	return


func _process(_delta: float) -> void:
	_ending_fade()
	if is_super_kill:
		if not is_super_defeat:
			super_kill()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	global_position.x = global_position.x - (delta * movement_per_second)
	return


func _on_window_size_changed() -> void:
	var viewport_length: float = get_viewport_rect().size.x
	var sprite_width: float = 60.0

	if position.x > (viewport_length - sprite_width):
		position.x = (viewport_length - sprite_width)
	return


func _on_punched() -> void:
	GameGlobals.audio_manager.create_audio("sound_punch")
	main_game_scene.apply_time_bonus(0.1)
	super_meter_handler.on_successful_punch()
	_on_defeated()


func _on_meteored() -> void:
	GameGlobals.audio_manager.create_audio("sound_explosion")
	_on_defeated()


func _on_deflected() -> void:
	GameGlobals.audio_manager.create_audio("sound_deflect")
	main_game_scene.apply_time_bonus(0.2)
	super_meter_handler.on_successful_deflect()
	_on_defeated()


func _on_defeated() -> void:
	is_defeat = true
	if is_instance_valid(sprite_2d):
		sprite_2d.queue_free()
		GameUtils.spawn_explosion(get_tree().current_scene, global_position)
	_begin_despawn()
	return


func _on_touching_player() -> void:
	get_tree().current_scene.player._on_hit_reaction()
	_begin_despawn()
	return


func _on_walk_past_player() -> void:
	_begin_despawn()
	pass


func _begin_despawn() -> void:
	var spawner: ObstacleSpawner = get_tree().current_scene.obstacle_spawner
	spawner.despawn_obstacle(current_lane, get_instance_id())

	queue_free()


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
