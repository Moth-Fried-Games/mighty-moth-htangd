extends Area2D
class_name PlayerHurtBox

@export var parry_time_window : float = 2
@onready var timer: Timer = $Timer
@onready var player_sprite: PlayerSprite = $"../PlayerSprite"

var hurtful_objects_colliding : Array[Area2D]
var collectable_objects_colliding : Array[Area2D]

var is_deflecting : bool = false

func _ready() -> void:
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)
	timer.timeout.connect(_stop_deflect)

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("ParryHitBoxArea")  and is_deflecting:
		player_sprite.play("deflect")
		area.owner._on_deflected()
	elif area.is_in_group("Collectable"):
		collectable_objects_colliding.append(area)
	elif area.is_in_group("HurtBoxArea"):
		if !is_deflecting:
			area.owner._on_touching_player()
		else:
			hurtful_objects_colliding.append(area)

func _on_area_exited(area: Area2D) -> void:
	if area.has_method("collect"):
		collectable_objects_colliding.erase(area)
	elif area is HurtBoxArea:
		hurtful_objects_colliding.erase(area)

func _stop_deflect() -> void:
	is_deflecting = false
	for object in hurtful_objects_colliding:
		if is_instance_valid(object):
			object.owner._on_touching_player()
		hurtful_objects_colliding.erase(object)

func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("collect"):     
		if collectable_objects_colliding.size() > 0:
			player_sprite.play("collect")   
		for object in collectable_objects_colliding:
			if is_instance_valid(object):
				object.owner._on_collected()
			collectable_objects_colliding.erase(object) # ERROR Attempted to erase an invalid (previously freed?) object instance into a TypedArray
	if Input.is_action_just_pressed("deflect"):        
		is_deflecting = true
		timer.start()
