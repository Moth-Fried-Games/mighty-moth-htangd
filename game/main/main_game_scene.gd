class_name MainGameScene
extends Node2D

@onready var lane_binders: Lanes = %LaneBinders
@onready var obstacle_spawner: ObstacleSpawner = %ObstacleSpawner
@onready var super_meter_handler: SuperMeterHandler = %SuperMeterHandler
@onready var ultimate: Marker2D = $Ultimate
@onready var stage_background: StageBackground = $StageBackground

var game_over_timer: Timer
var finale_timer: Timer

const game_over_timer_start: float = 60
const finale_timer_start: float = 180

var souvenirs_collected: int = 0
var good_ending_threshold: int = 10

var player: Player

## TODOS
# Go with my gut and make additional adjustments before handing off for Myr to build!
##


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameUi.ui_transitions.toggle_transition(false)

	game_over_timer = Timer.new()
	finale_timer = Timer.new()

	game_over_timer.wait_time = game_over_timer_start
	game_over_timer.one_shot = true

	finale_timer.wait_time = finale_timer_start
	finale_timer.one_shot = true

	add_child(game_over_timer)
	add_child(finale_timer)

	game_over_timer.start()
	finale_timer.start()

	player = $"Player"


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func apply_time_bonus(time_bonus: float) -> void:
	var currenttime: float = game_over_timer.get_time_left()

	var newtime: float = currenttime + (time_bonus * 3)  ## TEST the *3 multiplier is an arbitrary test, rebalance for real release
	if newtime > game_over_timer_start:  # Capping the timer to never go over the starting time limit
		newtime = game_over_timer_start

	game_over_timer.start(newtime)
