class_name MeleeEnemy
extends LaneEntity

var lane_id: Lanes.LaneId = Lanes.LaneId.MIDDLE



enum State { ARRIVING, IDLE, WINDUP, DEFEATED, ESCAPE }


const spawn_offset_from_anchor: float = 20
const movement_per_second: float = 200

@onready var obstacle_spawner: Node2D = %ObstacleSpawner
@onready var super_meter_handler: Node2D = %SuperMeterHandler

@onready var hurtboxarea: Area2D = $"HurtBoxArea"
@onready var meleehitboxarea: Area2D = $"MeleeHitBoxArea"
@onready var parryhitboxarea: Area2D = $"ParryHitBoxArea"



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
	print("owie I am puncheded")
	_on_defeated()
	## TODO apply time and super meter bonus, animate
	
func _on_deflected() -> void:
	print("oh wow I am deflecteded")
	_on_defeated()
	## TODO apply time and super meter bonus, animate

func _on_defeated() -> void:
	print("and thus I am deadddd")
	_begin_despawn()
	## TODO defeat animation
	pass
	
func _on_touching_player() -> void:
	print("you SMELL")
	_begin_despawn()
	## TODO break combo, annoy mightymoth a little
	pass

func _on_walk_past_player() -> void:
	print("I've walked past the despawn boundary!")
	_begin_despawn()
	## TODO break player's combo
	pass

func _begin_despawn() -> void:
	print("I'm gonna despawn now byeeeeeee")
	hurtboxarea.queue_free()
	meleehitboxarea.queue_free()
	parryhitboxarea.queue_free()
	
	var spawner = get_tree().current_scene.obstacle_spawner
	spawner.despawn_obstacle(lane_id, get_instance_id())
	
	var despawn_timer = Timer.new()
	despawn_timer.wait_time = 4
	despawn_timer.one_shot = true
	despawn_timer.timeout.connect(func() -> void: free())
