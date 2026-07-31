class_name Player
extends LaneEntity

enum PlayerState { IDLE, PUNCH, DEFLECT, COLLECT, SUPER_IDLE, SUPER_ATTACK, FINALE_SUPER }

const horizontal_offset_from_anchor = 200
@onready var middle_left_anchor: Marker2D = $"../LaneBinders/Middle Lane/Middle Left Anchor"
@onready var player_sprite: PlayerSprite = $PlayerSprite

var cutscene: bool = false
var super_mode: bool = false
var super_level_active: int = 0
var super_meter_handler: SuperMeterHandler
var main_scene: MainGameScene
var ultimate_scene: Marker2D
var stage_background: StageBackground

var on_hit_timer: Timer

var super_targets: Array[Node2D] = []
var ultimate_tween: Tween = null

## TODO LIST FOR SUPER MODE
#Super Mode:
#- The game 'pauses'
#- Timers pause
#- A QTE minigame plays with an input for each hostile entity visible in the screen (enemies, debris, projectiles)
#- Destroying everything (doing all the inputs) or messing up before the last input ends the Super and resumes normal gameplay
#- Destroying things during the super makes the Countdown increase
#- At lvl 1 you get x1 times the Countdown recovery
#- At lvl 2 you get x2 times the Countdown recovery
#- At lvl 3 you get x4 times the Countdown recovery
#- After Super is over, Reset Lvl and Bar to 0
## TODO LIST FOR SUPER MODE


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameGlobals.game_dictionary["node"]["player"] = self

	current_lane = Lanes.LaneId.MIDDLE

	global_position.x = middle_left_anchor.global_position.x + horizontal_offset_from_anchor

	_set_lane(current_lane)

	on_hit_timer = Timer.new()
	on_hit_timer.one_shot = true
	on_hit_timer.wait_time = 0.5
	on_hit_timer.timeout.connect(func() -> void: player_sprite.visible = true)
	add_child(on_hit_timer)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta: float) -> void:
	if not is_instance_valid(main_scene):
		main_scene = get_parent()
		stage_background = main_scene.stage_background
		ultimate_scene = main_scene.ultimate
		super_meter_handler = main_scene.super_meter_handler

	if cutscene:
		return
	if !super_mode:
		_movement()
		_animate()
		_on_super_input()
	else:  ## Processing movement/animations/changes during super mode
		return


# Up and down input processing
func _movement() -> void:
	if Input.is_action_just_pressed("move_up"):
		_change_lane(direction.UP)
		player_sprite.play("fly")
	if Input.is_action_just_pressed("move_down"):
		_change_lane(direction.DOWN)
		player_sprite.play("fly")


# Updating punch animation
func _animate() -> void:
	if Input.is_action_just_pressed("punch"):
		player_sprite.play("punch")
	if !on_hit_timer.is_stopped():
		player_sprite.visible = !player_sprite.visible
		return


func _on_hit_reaction() -> void:
	if on_hit_timer.is_stopped():
		super_meter_handler.on_combo_break()
		GameGlobals.audio_manager.create_audio("sound_punch")
		on_hit_timer.start()


# TODO; super implementation
func _on_super_input() -> void:
	if Input.is_action_just_pressed("ultimate"):
		super_meter_handler.apply_meter_gain(100)
		print("I think my super meter is... " + str(super_meter_handler.super_level))
		if super_meter_handler.super_level >= 1:
			print("Testing the super pause!!!")

			process_mode = Node.PROCESS_MODE_ALWAYS

			super_level_active = super_meter_handler.super_level

			#self.paused = false ## Invalid assignment of property or key 'paused' with value of type 'bool' on a base object of type 'Area2D (Player)'.
			## hmmm
			get_tree().paused = true
			super_mode = true
			_super_animation()
		return


func _super_sound(repeat: int, delay: float) -> void:
	for i in repeat:
		await get_tree().create_timer(delay).timeout
		GameGlobals.audio_manager.create_audio("sound_super")


func _super_animation() -> void:
	# setup
	super_targets = []
	for target in get_tree().get_nodes_in_group("ultimate"):
		if is_instance_valid(target):
			if not target.is_defeat:
				if "is_moving" in target:
					if target.is_moving:
						super_targets.append(target as Node2D)
				else:
					super_targets.append(target as Node2D)
	super_targets.shuffle()
	player_sprite.play("ultimate")
	ultimate_tween = create_tween()
	ultimate_tween.tween_property(stage_background, "modulate", Color.DIM_GRAY, 0.5)
	await ultimate_tween.finished

	# make player aura farm and fade away
	await _super_sound(10, 0.1)
	ultimate_tween = create_tween()
	ultimate_tween.tween_property(self, "modulate:a", 0, 1)
	await ultimate_tween.finished

	# attack the targets
	while super_targets.size() > 0:
		var current_target: Node2D = super_targets.pop_back()
		GameUtils.spawn_punch(ultimate_scene, current_target.global_position, current_target)
		await get_tree().create_timer(0.1).timeout
	await get_tree().create_timer(0.5).timeout

	# fade player back in
	ultimate_tween = create_tween()
	ultimate_tween.tween_property(self, "modulate:a", 1, 1)
	await ultimate_tween.finished

	ultimate_tween = create_tween()
	ultimate_tween.tween_property(stage_background, "modulate", Color.WHITE, 0.5)
	await ultimate_tween.finished
	player_sprite.play("fly")

	_on_super_finished()


func _on_super_finished() -> void:
	print("Ding! Super Mode is over!")
	super_meter_handler.expend_super_meter()
	super_mode = false
	get_tree().paused = false
	process_mode = Node.PROCESS_MODE_INHERIT
	return
