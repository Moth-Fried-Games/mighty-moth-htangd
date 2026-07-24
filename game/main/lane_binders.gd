@tool
class_name Lanes
extends Node2D

@onready var middle_lane: Node2D = %"Middle Lane"
@onready var middle_left_anchor: Marker2D = %"Middle Left Anchor"
@onready var middle_right_anchor: Marker2D = %"Middle Right Anchor"
@onready var bottom_lane: Node2D = %"Bottom Lane"
@onready var bottom_left_anchor: Marker2D = %"Bottom Left Anchor"
@onready var bottom_right_anchor: Marker2D = %"Bottom Right Anchor"
@onready var top_lane: Node2D = %"Top Lane"
@onready var top_left_anchor: Marker2D = %"Top Left Anchor"
@onready var top_right_anchor: Marker2D = %"Top Right Anchor"

enum LaneId { TOP = -1, MIDDLE = 0, BOTTOM = 1, INVALID = -999 }

@export var center_offset: int = 0:
	set(v):
		center_offset = v
		_update_lanes()
@export var lane_gaps: int = 50:
	set(v):
		lane_gaps = v
		_update_lanes()
@export var left_offset: int = -20:
	set(v):
		left_offset = v
		_update_lanes()
@export var right_offset: int = 20:
	set(v):
		right_offset = v
		_update_lanes()


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_update_lanes()


# Updates lane and anchor positions
func _update_lanes() -> void:
	if is_instance_valid(middle_lane):
		var viewport_size: Vector2 = get_viewport_rect().size

		position = (viewport_size / 2) + Vector2(0, center_offset)
		middle_lane.position = Vector2.ZERO
		bottom_lane.position = Vector2.ZERO + Vector2(0, lane_gaps)
		top_lane.position = Vector2.ZERO + Vector2(0, -lane_gaps)

		middle_left_anchor.position = Vector2(-(viewport_size.x / 2) + left_offset, 0)
		top_left_anchor.position = Vector2(-(viewport_size.x / 2) + left_offset, 0)
		bottom_left_anchor.position = Vector2(-(viewport_size.x / 2) + left_offset, 0)

		middle_right_anchor.position = Vector2((viewport_size.x / 2) + right_offset, 0)
		top_right_anchor.position = Vector2((viewport_size.x / 2) + right_offset, 0)
		bottom_right_anchor.position = Vector2((viewport_size.x / 2) + right_offset, 0)

	pass


# Retrieves a given lane's y pos
func get_y_position(lane_id: LaneId) -> float:
	match lane_id:
		LaneId.TOP:
			return top_lane.global_position.y
		LaneId.MIDDLE:
			return middle_lane.global_position.y
		LaneId.BOTTOM:
			return bottom_lane.global_position.y
	return INF


func get_collision_mask(lane_id: LaneId) -> int:  # COLLISION MASKS PENDING REVISION
	match lane_id:
		LaneId.TOP:
			return 1
		LaneId.MIDDLE:
			return 2
		LaneId.BOTTOM:
			return 3
	return -1
