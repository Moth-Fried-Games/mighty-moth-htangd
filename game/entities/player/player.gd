extends LaneEntity

enum PlayerState { IDLE, PUNCH, DEFLECT, COLLECT, SUPER_IDLE, SUPER_ATTACK, FINALE_SUPER}

const horizontal_offset_from_anchor = 150
@onready var middle_left_anchor: Marker2D = $"../LaneBinders/Middle Lane/Middle Left Anchor"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var midle_lane : int = lanes_quantity / 2 
	
	current_lane = midle_lane
	
	global_position.x = middle_left_anchor.global_position.x + horizontal_offset_from_anchor
	
	_set_lane(current_lane)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	_movement()

func _movement():
	if Input.is_action_just_pressed("move_up"):
		_change_lane(direction.UP)
	if Input.is_action_just_pressed("move_down"):
		_change_lane(direction.DOWN)

## TODO
func _on_attack_input():
	pass
## TODO
func _on_deflect_input():
	pass
## TODO
func _on_collect_input():
	pass
