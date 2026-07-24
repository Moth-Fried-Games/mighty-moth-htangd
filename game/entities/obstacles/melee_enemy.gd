class_name MeleeEnemy
extends LaneEntity

var lane_id: Lanes.LaneId = Lanes.LaneId.MIDDLE



enum State { ARRIVING, IDLE, WINDUP, DEFEATED, ESCAPE }

const horizontal_offset_base: float = 150
var horizontal_offset_wiggle: float = 0
var horizontal_offset_wiggle_direction: int = -1
const horizontal_offset_wiggle_absolute_max: float = 15 
const horizontal_wiggle_per_second: float = 15




# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var lane_binder: Lanes = get_tree().current_scene.lane_binders
	global_position = Vector2(_get_horizontal_position(), lane_binder.get_y_position(lane_id)) ## TODO lane_binders is null? Why???
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	_wiggle_horiz_position(delta)
	global_position.x = _get_horizontal_position()
	return


func _wiggle_horiz_position(delta: float) -> void:
	horizontal_offset_wiggle += (horizontal_offset_wiggle_direction * delta * horizontal_wiggle_per_second)
	
	if horizontal_offset_wiggle_direction == 1 and horizontal_offset_wiggle >= horizontal_offset_wiggle_absolute_max:
		horizontal_offset_wiggle_direction = -1
		var leftover_wiggle = horizontal_offset_wiggle - horizontal_offset_wiggle_absolute_max
		horizontal_offset_wiggle = horizontal_offset_wiggle - leftover_wiggle
	
	elif horizontal_offset_wiggle_direction == -1 and horizontal_offset_wiggle <= -horizontal_offset_wiggle_absolute_max:
		horizontal_offset_wiggle_direction = 1
		var leftover_wiggle = horizontal_offset_wiggle_absolute_max + horizontal_offset_wiggle
		horizontal_offset_wiggle = horizontal_offset_wiggle - leftover_wiggle
	
	
	return

func _get_horizontal_position() -> float:
	return horizontal_offset_base + horizontal_offset_wiggle
