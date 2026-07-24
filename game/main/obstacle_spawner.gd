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

# Spawn another "wave" of obstacles as per the timer's timed interval
## Currently, this is just one at a time. What if we sometimes spawn 2 or 3 at a time, with proper timing?
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
			ObstacleType.RANGED_ENEMY:
				pass # TODO create scene for this obstacle type and actually implement it
			ObstacleType.DEBRIS:
				pass # TODO create scene for this obstacle type and actually implement it
			ObstacleType.SOUVENIR:
				pass # TODO create scene for this obstacle type and actually implement it
	else:
		print("... but there's no valid spawns available!!!")
	
	spawn_timer.start()
	return
	
# Algorithm to decide which obstacle type should spawn next
func _decide_obstacles_to_spawn() -> ObstacleType:
	## TODO; currently automatically returning MELEE_ENEMY for simple testing purposes. Need to algorithmically decide between different types
	## Needs include...
	### Guarantee a Souvenir spawn every X seconds or so
	### Spawn a diverse range of melee enemies, ranged enemies, and debris
	### Avoid spawning obs at a timing that would guarantee a combo break
	return ObstacleType.MELEE_ENEMY
	
# Algorithm to decide which lane a given obstacle type should spawn in
func _decide_lane_to_spawn_in(spawn_type: ObstacleType) -> Lanes.LaneId:
	if current_obstacle_map.values().all(func(obs_in_lane) -> bool: 
		return _find_obstacletype_in_array(spawn_type, obs_in_lane)):
		return Lanes.LaneId.INVALID
	
	var ret: Lanes.LaneId = Lanes.LaneId.INVALID
	
	while ret == Lanes.LaneId.INVALID:
		ret = (pattern_randomizer.randi() % 3 - 1)
		if current_obstacle_map[ret].size() > 0: # Re-assign the lane
			## TODO this algorithm is inefficient, revise it to always roll once and only once when I have the time
			print("Can't spawn another one on lane " + str(ret))
			ret = Lanes.LaneId.INVALID
		
	
		
	return ret

# Returns true IF the array obs_in_lane contains one or more items matching a given obstacle type
func _find_obstacletype_in_array(spawn_type: ObstacleType, obs_in_lane: Array) -> bool:
	if obs_in_lane.any(func(single_obs): 
		return _match_enum_by_class(spawn_type, single_obs)):
		return true
	return false

# Confirms whether the obstacle enum matches the Node's class name
func _match_enum_by_class(spawn_type: ObstacleType, single_obs: Node) -> bool:
	if spawn_type == ObstacleType.MELEE_ENEMY:
		return single_obs is MeleeEnemy
	## TODO add checks for additional obstacle types and class names when implemented
	return false
