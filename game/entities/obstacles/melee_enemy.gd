class_name MeleeEnemy
extends LaneEntity

var lane_id: Lanes.LaneId = Lanes.LaneId.MIDDLE



enum State { ARRIVING, IDLE, WINDUP, DEFEATED, ESCAPE }


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



func _on_punched() -> void:
	_on_defeated()
	## TODO apply time and super meter bonus, animate
	
func _on_deflected() -> void:
	_on_defeated()
	## TODO apply time and super meter bonus, animate

func _on_defeated() -> void:
	## TODO Begin to despawn
	pass
	
func _on_touching_player() -> void:
	## TODO break combo, annoy mightymoth a little
	pass

func _on_walk_past_player() -> void:
	## TODO _begin_despawn this enemy and, IF AND ONLY IF the enemy didn't touch this player, break their combo
	pass

func _begin_despawn() -> void:
	## TODO remove the enemy from the ObstacleSpawner's tracker! Then, set a timer to WAIT a few seconds to ensure that completes. When the timer expires, delete this node
	pass
