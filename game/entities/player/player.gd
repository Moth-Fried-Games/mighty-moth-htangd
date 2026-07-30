class_name Player
extends LaneEntity

enum PlayerState { IDLE, PUNCH, DEFLECT, COLLECT, SUPER_IDLE, SUPER_ATTACK, FINALE_SUPER }

const horizontal_offset_from_anchor = 150
@onready var middle_left_anchor: Marker2D = $"../LaneBinders/Middle Lane/Middle Left Anchor"
@onready var player_sprite: PlayerSprite = $PlayerSprite

var cutscene: bool = false
var super_mode: bool = false
var super_level_active: int = 0
var super_meter_handler: SuperMeterHandler = null

var super_mode_timer: Timer
var super_mode_time_limit: float = 3.0
var super_mode_counter: int = 0

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
	
	
	
	super_mode_timer = Timer.new()
	super_mode_timer.one_shot = true
	super_mode_timer.timeout.connect(func () -> void: 
		_on_super_finished()
	)
	
	add_child(super_mode_timer)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta: float) -> void:
	if cutscene:
		return
	if !super_mode:
		_movement()
		_animate()
		_on_super_input()
	else: ## Processing movement/animations/changes during super mode
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

# TODO; super implementation
func _on_super_input() -> void:
	if Input.is_action_just_pressed("ultimate"):
		super_meter_handler = get_tree().current_scene.super_meter_handler
		
		print("I think my super meter is... " + str(super_meter_handler.super_level))
		if super_meter_handler.super_level >= 1:
			print("Testing the super pause!!!")
			
			process_mode = Node.PROCESS_MODE_ALWAYS
			
			
			super_level_active = super_meter_handler.super_level
			super_meter_handler.expend_super_meter()
			
			#self.paused = false ## Invalid assignment of property or key 'paused' with value of type 'bool' on a base object of type 'Area2D (Player)'.
			## hmmm
			get_tree().paused = true
			super_mode = true
			
			super_mode_timer.wait_time = super_mode_time_limit
			super_mode_timer.start()
		return
		
func _on_super_successful_input() -> void:
	super_mode_counter += 1
	super_mode_timer.start(super_mode_time_limit - (0.1 * super_mode_counter))
	return

func _on_super_finished() -> void:
	if !super_mode_timer.is_stopped():
		super_mode_timer.stop()
		
	print("Ding! Super Mode is over!")
	
	super_mode_counter = 0
	super_mode = false
	get_tree().paused = false
	process_mode = Node.PROCESS_MODE_INHERIT
	return
