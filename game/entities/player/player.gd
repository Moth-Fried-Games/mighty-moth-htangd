extends RigidBody2D

@export var lanes : Array[Node2D]

var lanes_quantity : int

var lane_positions : Array[Vector2]

var current_lane : int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	lanes_quantity = lanes.size()
	
	var i = 0
	for lane in lanes:
		lane_positions[i] = lane.global_position
		i += 1
	
	lane_positions.sort_custom(func(a, b): return a.x[1] < b.x[1])
	
	var midle_lane : int = lane_positions.size() / 2
	
	current_lane = midle_lane
	
	_set_lane(current_lane)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _set_lane(lane : int):
	global_position.x = lane_positions[lane].x

func  _change_lane(direction : int):
	var cant_move_condition = (
			(current_lane == 0 and direction == -1) 
			or (current_lane == lanes_quantity - 1 and direction == 1)
		)
	
	if cant_move_condition:
		pass
	
	current_lane += direction
	
	_set_lane(current_lane)
