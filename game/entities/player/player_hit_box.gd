extends Area2D
class_name PlayerHitBox

@onready var player_sprite: PlayerSprite = $"../PlayerSprite"
@onready var timer: Timer = $Timer
@onready var parry_cooldown_timer: Timer = $ParryCooldownTimer

var punchble_objects_colliding : Array[Area2D]
var collectable_objects_colliding : Array[Area2D]
var parryable_objects_colliding : Array[Area2D]

var is_deflecting : bool = false
signal on_parry_recharge

func _ready() -> void:
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)
	timer.timeout.connect(_stop_deflect)
	
# Confirming the colliding entity is in the same lane as the player
func _is_in_same_lane(colliding_area: Area2D) -> bool:
	if colliding_area.owner is LaneEntity:
		return colliding_area.owner.current_lane == owner.current_lane
	return false

func _on_area_entered(area: Area2D) -> void:	
	if _is_in_same_lane(area):
		
		if area.is_in_group("ParryHitBoxArea"):
			parryable_objects_colliding.append(area)
		
		if area.is_in_group("MeleeHitBoxArea"):
			punchble_objects_colliding.append(area)
		
		if area.is_in_group("Collectable"):
			collectable_objects_colliding.append(area)
			
		

func _on_area_exited(area: Area2D) -> void:
	if punchble_objects_colliding.has(area) and area.is_in_group("MeleeHitBoxArea"):
		punchble_objects_colliding.erase(area)
		
	if collectable_objects_colliding.has(area) and area.has_method("collect"):
		collectable_objects_colliding.erase(area)
		
	if parryable_objects_colliding.has(area):
		parryable_objects_colliding.erase(area)
		
func _stop_deflect() -> void:
	is_deflecting = false

func _physics_process(_delta: float) -> void:
	if is_deflecting:
		for object in parryable_objects_colliding:
			object.owner._on_deflected()
			parryable_objects_colliding.erase(object)
	
	if Input.is_action_just_pressed("deflect") and parry_cooldown_timer.is_stopped():
		player_sprite.play("deflect")        
		is_deflecting = true
		timer.start()
		parry_cooldown_timer.start()
		return
	elif is_deflecting and (Input.is_action_just_pressed("collect") or Input.is_action_just_pressed("punch")):
		is_deflecting = false
	
	var isPunching: bool = player_sprite.punching
	if isPunching:
		for object in punchble_objects_colliding:
			if is_instance_valid(object):
				object.owner._on_punched()
				punchble_objects_colliding.erase(object)
	elif Input.is_action_just_pressed("collect"):     
		player_sprite.play("collect")   
		for object in collectable_objects_colliding:
			if is_instance_valid(object):
				object.owner._on_collected()
				collectable_objects_colliding.erase(object)
				
func _reset_parry_timers() -> void:
	is_deflecting = false
	if !timer.is_stopped():
		timer.stop()
	if !parry_cooldown_timer.is_stopped():
		parry_cooldown_timer.stop()
		on_parry_recharge.emit()
