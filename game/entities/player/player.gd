class_name Player
extends LaneEntity

enum PlayerState { IDLE, PUNCH, DEFLECT, COLLECT, SUPER_IDLE, SUPER_ATTACK, FINALE_SUPER }

const horizontal_offset_from_anchor = 150
@onready var middle_left_anchor: Marker2D = $"../LaneBinders/Middle Lane/Middle Left Anchor"
@onready var player_sprite: PlayerSprite = $PlayerSprite

var cutscene: bool = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameGlobals.game_dictionary["node"]["player"] = self

	var midle_lane: int = int(float(lanes_quantity) / 2)

	current_lane = midle_lane

	global_position.x = middle_left_anchor.global_position.x + horizontal_offset_from_anchor

	_set_lane(current_lane)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta: float) -> void:
	if cutscene:
		return
	_movement()
	_animate()


func _movement() -> void:
	if Input.is_action_just_pressed("move_up"):
		_change_lane(direction.UP)
		player_sprite.play("fly")
	if Input.is_action_just_pressed("move_down"):
		_change_lane(direction.DOWN)
		player_sprite.play("fly")
		
func _animate() -> void:
	if Input.is_action_just_pressed("punch"):
		player_sprite.play("punch")
	if Input.is_action_just_pressed("collect"):
		player_sprite.play("collect")
	if Input.is_action_just_pressed("deflect"):
		player_sprite.play("deflect")

func _on_super_input() -> void:
	pass
