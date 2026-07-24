extends Node2D

const MELEE_ENEMY = preload("uid://bl702ass4bwy5")

const starting_difficulty_value: int = 0
const difficulty_increment_timer: float = 15
const endgame_timer_threshold: float = 180

var spawn_timer_waittime: float = 4.0
var spawn_time_maximum: float = 4.0
var spawn_timer_minimum: float = 2.0
var spawn_timer_decrement: float = 0.1

var current_obstacle_map: Dictionary = {
	Lanes.LaneId.TOP: [],
	Lanes.LaneId.MIDDLE: [],
	Lanes.LaneId.BOTTOM: []
}

var pattern_randomizer: RandomNumberGenerator = RandomNumberGenerator.new()
var spawn_timer: Timer

enum ObstacleType { MELEE_ENEMY, RANGED_ENEMY, SOUVENIR, DEBRIS }

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	spawn_timer = Timer.new()
	spawn_timer.wait_time = 2.0
	spawn_timer.timeout.connect(_spawn_obstacles_wave)
	spawn_timer.one_shot = false
	add_child(spawn_timer)
	print("Starting obstacle timer!")
	spawn_timer.start()
	return


## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass

func _spawn_obstacles_wave() -> void:
	print("Timer has dinged!")
	
	var obstacle_to_spawn: ObstacleType = _decide_obstacles_to_spawn()
	var lane_to_spawn_in: Lanes.LaneId = _decide_lane_to_spawn_in(obstacle_to_spawn)
	
	if lane_to_spawn_in != Lanes.LaneId.INVALID:
		match obstacle_to_spawn:
			ObstacleType.MELEE_ENEMY:
				var new_enemy_spawn: MeleeEnemy = MELEE_ENEMY.instantiate() 
				new_enemy_spawn.lane_id = lane_to_spawn_in
				owner.add_child(new_enemy_spawn)
				current_obstacle_map[lane_to_spawn_in].append(new_enemy_spawn)
				print("Spawned a melee enemy!")
	else:
		print("... but there's no valid spawns available!!!")
	### CURRENTLY TESTING
	#var new_enemy_spawn: MeleeEnemy = MELEE_ENEMY.instantiate() 
	#var new_enemy_lane: Lanes.LaneId = (pattern_randomizer.randi() % 3 - 1)
	#new_enemy_spawn.lane_id = new_enemy_lane
	#owner.add_child(new_enemy_spawn)
	#current_obstacle_map[new_enemy_lane].append(new_enemy_spawn)
	### CURRENTLY TESTING
	
	spawn_timer.start()
	return
	
func _decide_obstacles_to_spawn() -> ObstacleType:
	return ObstacleType.MELEE_ENEMY
	
func _decide_lane_to_spawn_in(spawn_type: ObstacleType) -> Lanes.LaneId:
	if current_obstacle_map.values().all(func(obs_in_lane) -> bool:  ## Invalid access to property or key 'values' on a base object of type 'Dictionary'.
		return _find_obstacletype_in_array(spawn_type, obs_in_lane)):
		return Lanes.LaneId.INVALID
	
	var ret: Lanes.LaneId = Lanes.LaneId.INVALID
	
	while ret == Lanes.LaneId.INVALID:
		ret = (pattern_randomizer.randi() % 3 - 1)
		if current_obstacle_map[ret].size() > 0:
			print("Can't spawn another one on lane " + str(ret))
			ret = Lanes.LaneId.INVALID
		
	
		
	return ret

func _find_obstacletype_in_array(spawn_type: ObstacleType, obs_in_lane: Array) -> bool:
	if obs_in_lane.any(func(single_obs): 
		return _match_enum_by_class(spawn_type, single_obs)):
		return true
	return false

func _match_enum_by_class(spawn_type: ObstacleType, single_obs: Node) -> bool:
	if spawn_type == ObstacleType.MELEE_ENEMY:
		return single_obs is MeleeEnemy
	return false
