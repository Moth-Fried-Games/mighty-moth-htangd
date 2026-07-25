extends Node2D

@onready var lane_binders: Lanes = %LaneBinders
@onready var obstacle_spawner: ObstacleSpawner = %ObstacleSpawner

var game_over_timer: Timer
var finale_timer: Timer

const game_over_timer_start: float = 60
const finale_timer_start: float = 180

@onready var gameover_timer_display: Label = $"PlaceholderTimer"
@onready var victory_timer_display: Label = $"PlaceholderVICTORYTimer"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameUi.ui_transitions.toggle_transition(false)
	
	game_over_timer = Timer.new()
	finale_timer = Timer.new()
	
	game_over_timer.wait_time = game_over_timer_start
	game_over_timer.timeout.connect(_on_game_over_countdown)
	game_over_timer.one_shot = true
	
	finale_timer.wait_time = finale_timer_start
	finale_timer.timeout.connect(_on_finale_countdown)
	finale_timer.one_shot = true
	
	add_child(game_over_timer)
	add_child(finale_timer)
	
	game_over_timer.start()
	finale_timer.start()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	gameover_timer_display.text = "TIME 2 DOOMSDAY\n" + str(game_over_timer.time_left)
	victory_timer_display.text = "SECRET VICTORY TIMER\n" + str(finale_timer.time_left)


func _on_game_over_countdown() -> void:
	## TODO PROCESS MORE CHANGES AS A PRODUCT OF THE GAME OVER TRIGGER
	finale_timer.stop()
	
func _on_finale_countdown() -> void:
	## TODO PROCESS MORE CHANGES AS A PRODUCT OF THE FINALE TRIGGER
	game_over_timer.stop()
