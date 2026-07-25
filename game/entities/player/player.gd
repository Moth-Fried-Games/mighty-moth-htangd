extends LaneEntity

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var midle_lane : int = lanes_quantity / 2 
	
	current_lane = midle_lane
	
	_set_lane(current_lane)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	_movement()

func _movement():
	if Input.is_action_just_pressed("move_up"):
		_change_lane(direction.UP)
	if Input.is_action_just_pressed("move_down"):
		_change_lane(direction.DOWN)
