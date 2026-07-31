extends Area2D
class_name PlayerHurtBox

@export var parry_time_window : float = 2
@onready var timer: Timer = $Timer
@onready var player_sprite: PlayerSprite = $"../PlayerSprite"

var hurtful_objects_colliding : Array[Area2D]

var is_deflecting : bool = false

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
		if area.is_in_group("ParryHitBoxArea")  and is_deflecting:
			player_sprite.play("deflect")
			area.owner._on_deflected()
		elif area.is_in_group("HurtBoxArea"):
			if !is_deflecting:
				area.owner._on_touching_player()
			else:
				hurtful_objects_colliding.append(area)

func _on_area_exited(area: Area2D) -> void:
	if area is HurtBoxArea and hurtful_objects_colliding.has(area):
		hurtful_objects_colliding.erase(area)

func _stop_deflect() -> void:
	is_deflecting = false
	for object in hurtful_objects_colliding:
		if is_instance_valid(object):
			object.owner._on_touching_player()
			hurtful_objects_colliding.erase(object)

func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("deflect"):        
		is_deflecting = true
		timer.start()
	else:
		print("Heyo that timer? It's got... " + str(timer.wait_time) + " left.")
