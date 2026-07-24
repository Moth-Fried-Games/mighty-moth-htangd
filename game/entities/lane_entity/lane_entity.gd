extends RigidBody2D
class_name LaneEntity

@export var lanes : Array[Node2D]

@onready var lanes_quantity : int = lanes.size()

@onready var lane_positions : Array[Vector2] = _return_lane_positions()

var current_lane : int

func _return_lane_positions():
	var lane_positions : Array[Vector2]
	
	lane_positions = []
	
	lane_positions.resize(lanes_quantity)
	
	var i = 0
	for lane in lanes:
		lane_positions[i] = lane.global_position
		i += 1
	
	lane_positions.sort_custom(func(a, b): return a.y < b.y)
	
	return lane_positions

func _set_lane(lane : int):
	current_lane = lane
	global_position.y = lane_positions[current_lane].y

func  _change_lane(direction : int ):
	var cant_move_condition = (
			(current_lane == 0 and direction == -1) 
			or (current_lane == lanes_quantity - 1 and direction == 1)
		)
	
	if cant_move_condition:
		return
	
	current_lane += direction
	
	_set_lane(current_lane)
