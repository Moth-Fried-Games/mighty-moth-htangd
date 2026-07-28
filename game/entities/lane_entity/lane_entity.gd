extends Area2D
class_name LaneEntity

enum direction {UP = -1, DOWN = 1}

@export var lanes : Array[Node2D]

@onready var lanes_quantity : int = lanes.size()

@onready var lane_positions : Array[Vector2] = _return_lane_positions()

var current_lane: Lanes.LaneId = Lanes.LaneId.MIDDLE

func _return_lane_positions() -> Array[Vector2]:
	#var lane_positions : Array[Vector2]
	
	lane_positions = []
	
	lane_positions.resize(lanes_quantity)
	
	var i: int = 0
	for lane in lanes:
		lane_positions[i] = lane.global_position
		i += 1
	
	lane_positions.sort_custom(func(a: Vector2, b: Vector2) -> bool: return a.y < b.y)
	
	return lane_positions

func _set_lane(lane: Lanes.LaneId) -> void:
	current_lane = lane
	global_position.y = lane_positions[current_lane + 1].y

func  _change_lane(dir : direction) -> void:
	var cant_move_condition: bool = (
			(current_lane == Lanes.LaneId.TOP and dir == direction.UP) 
			or (current_lane == Lanes.LaneId.BOTTOM and dir == direction.DOWN)
		)
	
	if cant_move_condition:
		return
	
	current_lane += dir as Lanes.LaneId
	
	_set_lane(current_lane)
