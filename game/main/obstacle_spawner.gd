class_name ObstacleSpawner
extends Node2D

const MELEE_ENEMY = preload("uid://bl702ass4bwy5")
const RANGED_ENEMY = preload("uid://ckkl1fo8xyo7d")
const SOUVENIR = preload("uid://pwnwhyevxnmt")
const DEBRIS = preload("uid://ceg558w8g2nov")

const SOUVENIR_RANDOM_TEXTURES = [
	preload("uid://bmdp5gh6nrqvg"),
	preload("uid://dpjid314waj0n"),
	preload("uid://w3idkocc38k"),
	preload("uid://bl2104j32ygpw"),
	preload("uid://by5q8td5b7jtf")
]


const starting_difficulty_value: int = 0
const difficulty_increment_timer: float = 15

var spawn_timer_waittime: float = 1.5
var spawn_time_maximum: float = 4.0
var spawn_timer_minimum: float = 2.0
var spawn_timer_decrement: float = 0.1

var souvenirs_spawned: int = 0
const souvenirs_total_spawnable: int = 20
const good_ending_threshold: int = 10
const souv_guaranteed_spawn_time: float = main_game_scene.finale_timer_start / souvenirs_total_spawnable 

var current_obstacle_map: Dictionary = {
	Lanes.LaneId.TOP: [],
	Lanes.LaneId.MIDDLE: [],
	Lanes.LaneId.BOTTOM: []
}

var pattern_randomizer: RandomNumberGenerator = RandomNumberGenerator.new()
var spawn_timer: Timer

enum ObstacleType { MELEE_ENEMY, RANGED_ENEMY, SOUVENIR, DEBRIS }

var main_game_scene: MainGameScene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	spawn_timer = Timer.new()
	spawn_timer.wait_time = 2.0
	spawn_timer.timeout.connect(_spawn_obstacles_wave)
	spawn_timer.one_shot = false
	add_child(spawn_timer)
	spawn_timer.start()
	
	main_game_scene = get_tree().current_scene
	
	return

# Spawn another "wave" of obstacles as per the timer's timed interval
## Currently, this is just one at a time. What if we sometimes spawn 2 or 3 at a time, with proper timing?
func _spawn_obstacles_wave() -> void:
	var obstacle_to_spawn: ObstacleType = _decide_obstacles_to_spawn()
	var lane_to_spawn_in: Lanes.LaneId = _decide_lane_to_spawn_in(obstacle_to_spawn)
	
	if lane_to_spawn_in != Lanes.LaneId.INVALID:
		match obstacle_to_spawn:
			ObstacleType.MELEE_ENEMY:
				var new_enemy_spawn: MeleeEnemy = MELEE_ENEMY.instantiate() 
				new_enemy_spawn.current_lane = lane_to_spawn_in
				new_enemy_spawn.global_position = global_position
				owner.add_child(new_enemy_spawn)
				current_obstacle_map.get(lane_to_spawn_in).append(new_enemy_spawn)
				print("Spawned a melee enemy!")
				
			ObstacleType.RANGED_ENEMY:
				var new_enemy_spawn: RangedEnemy = RANGED_ENEMY.instantiate() 
				new_enemy_spawn.current_lane = lane_to_spawn_in
				new_enemy_spawn.global_position = global_position
				owner.add_child(new_enemy_spawn)
				current_obstacle_map.get(lane_to_spawn_in).append(new_enemy_spawn)
				print("Spawned a ranged enemy!")
				
			ObstacleType.DEBRIS:
				var new_debris_spawn: Debris = DEBRIS.instantiate()
				new_debris_spawn.current_lane = lane_to_spawn_in
				new_debris_spawn.global_position = global_position
				owner.add_child(new_debris_spawn)
				current_obstacle_map.get(lane_to_spawn_in).append(new_debris_spawn)
				print("Spawned debris!")
				
			ObstacleType.SOUVENIR:
				var new_souv_spawn: Souvenir = SOUVENIR.instantiate()
				
				var souv_texture_index: int = pattern_randomizer.randi() % 5
				new_souv_spawn.assignedSprite = SOUVENIR_RANDOM_TEXTURES[souv_texture_index]
				
				## TODO randomly assign this souv a texture using the rng and a memory of previously spawned souvs
				new_souv_spawn.current_lane = lane_to_spawn_in
				new_souv_spawn.global_position = global_position
				owner.add_child(new_souv_spawn)
				current_obstacle_map.get(lane_to_spawn_in).append(new_souv_spawn)
				souvenirs_spawned += 1
				print("Spawned a souv!! GET IT NERD")
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
	
	if ((main_game_scene.finale_timer_start - main_game_scene.finale_timer.time_left) / souv_guaranteed_spawn_time) > souvenirs_spawned:
		return ObstacleType.SOUVENIR
		
	var weighted_choice_array: Array = [
		ObstacleType.MELEE_ENEMY, ObstacleType.MELEE_ENEMY, ObstacleType.MELEE_ENEMY, ObstacleType.MELEE_ENEMY, ObstacleType.MELEE_ENEMY, ObstacleType.MELEE_ENEMY, ObstacleType.MELEE_ENEMY,
		ObstacleType.RANGED_ENEMY, ObstacleType.RANGED_ENEMY, ObstacleType.RANGED_ENEMY, ObstacleType.RANGED_ENEMY,
		ObstacleType.DEBRIS, ObstacleType.DEBRIS, ObstacleType.DEBRIS,
		ObstacleType.SOUVENIR,
	]
	
	if souvenirs_spawned == souvenirs_total_spawnable:
		weighted_choice_array.remove_at(weighted_choice_array.find(ObstacleType.SOUVENIR))
	
	var ret_index: int = pattern_randomizer.randi() % weighted_choice_array.size()
	
	return weighted_choice_array[ret_index]
	
# Algorithm to decide which lane a given obstacle type should spawn in
func _decide_lane_to_spawn_in(spawn_type: ObstacleType) -> Lanes.LaneId:
	var lane_options: Array = current_obstacle_map.keys().filter(func(key: Lanes.LaneId) -> bool: 
		if spawn_type == ObstacleType.MELEE_ENEMY:
			return true
		else:
			return !_find_obstacletype_in_array(spawn_type, current_obstacle_map.get(key))
	)
	
	if lane_options.size() > 1:
		return lane_options[(pattern_randomizer.randi() % lane_options.size())]
	elif lane_options.size() == 1:
		return lane_options[0]
	else:
		return Lanes.LaneId.INVALID

# Returns true IF the array obs_in_lane contains one or more items matching a given obstacle type
func _find_obstacletype_in_array(spawn_type: ObstacleType, obs_in_lane: Array) -> bool:
	return obs_in_lane.any(func(single_obs: LaneEntity) -> bool: 
		return _match_enum_by_class(spawn_type, single_obs)
	)
	
# Confirms whether the obstacle enum matches the Node's class name
func _match_enum_by_class(spawn_type: ObstacleType, single_obs: Node) -> bool:
	match spawn_type:
		ObstacleType.MELEE_ENEMY:
			return single_obs is MeleeEnemy
		ObstacleType.RANGED_ENEMY:
			return single_obs is RangedEnemy
		ObstacleType.DEBRIS:
			return single_obs is Debris
		ObstacleType.SOUVENIR:
			return single_obs is Souvenir
	return false
	
# Removes an obstacle from our list of tracked items per lane, freeing up another of that item to spawn in it again
func despawn_obstacle(laneId: Lanes.LaneId, nodeid: int) -> void:
	var obstacle_to_remove: int = current_obstacle_map.get(laneId).find_custom(func(obs: LaneEntity) -> bool:
		return obs.get_instance_id() == nodeid)
	if obstacle_to_remove != -1:
		current_obstacle_map.get(laneId).remove_at(obstacle_to_remove)
