class_name MeleeEnemy
extends LaneEntity

var lane_id: Lanes.LaneId = Lanes.LaneId.MIDDLE



enum State { ARRIVING, IDLE, WINDUP, DEFEATED, ESCAPE }

## NOTE this placeholder wiggle was like fun but it CANNOT stay, I gotta make the enemy WALK the whole way across the screen
#const horizontal_offset_base: float = 150
#var horizontal_offset_wiggle: float = 0
#var horizontal_offset_wiggle_direction: int = -1
#const horizontal_offset_wiggle_absolute_max: float = 15 
#const horizontal_wiggle_per_second: float = 15


const spawn_offset_from_anchor: float = 20
const movement_per_second: float = 200



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var lane_binder: Lanes = get_tree().current_scene.lane_binders
	
	var back_spawn_anchor: Marker2D = null
	match lane_id:
		Lanes.LaneId.TOP:
			back_spawn_anchor = lane_binder.top_right_anchor
		Lanes.LaneId.MIDDLE:
			back_spawn_anchor = lane_binder.middle_right_anchor
		Lanes.LaneId.BOTTOM:
			back_spawn_anchor = lane_binder.bottom_right_anchor
		
	
	global_position = Vector2(back_spawn_anchor.global_position.x, back_spawn_anchor.global_position.y)
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#_wiggle_horiz_position(delta)
	global_position.x = global_position.x - (delta * movement_per_second) #_get_horizontal_position()
	return


#func _wiggle_horiz_position(delta: float) -> void:
	#horizontal_offset_wiggle += (horizontal_offset_wiggle_direction * delta * horizontal_wiggle_per_second)
	#
	#if horizontal_offset_wiggle_direction == 1 and horizontal_offset_wiggle >= horizontal_offset_wiggle_absolute_max:
		#horizontal_offset_wiggle_direction = -1
		#var leftover_wiggle = horizontal_offset_wiggle - horizontal_offset_wiggle_absolute_max
		#horizontal_offset_wiggle = horizontal_offset_wiggle - leftover_wiggle
	#
	#elif horizontal_offset_wiggle_direction == -1 and horizontal_offset_wiggle <= -horizontal_offset_wiggle_absolute_max:
		#horizontal_offset_wiggle_direction = 1
		#var leftover_wiggle = horizontal_offset_wiggle_absolute_max + horizontal_offset_wiggle
		#horizontal_offset_wiggle = horizontal_offset_wiggle - leftover_wiggle
	#
	#
	#return
#
#func _get_horizontal_position() -> float:
	#return horizontal_offset_base + horizontal_offset_wiggle
	

func _on_punched() -> void:
	_on_defeated()
	
func _on_deflected() -> void:
	_on_defeated()

func _on_defeated() -> void:
	pass
	
func _on_touching_player() -> void:
	pass

func _on_walk_past_player() -> void:
	pass
