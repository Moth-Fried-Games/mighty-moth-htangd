extends Area2D

@onready var player_sprite: PlayerSprite = $"../PlayerSprite"

var collectable_objects_colliding : Array[Area2D]


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)

# Confirming the colliding entity is in the same lane as the player
func _is_in_same_lane(colliding_area: Area2D) -> bool:
	if colliding_area.owner is LaneEntity:
		return colliding_area.owner.current_lane == owner.current_lane
	return false

func _on_area_entered(area: Area2D) -> void:
	if _is_in_same_lane(area):
		if area.is_in_group("Collectable"):
			collectable_objects_colliding.append(area)

func _on_area_exited(area: Area2D) -> void:
	if area.has_method("collect") and collectable_objects_colliding.has(area):
		collectable_objects_colliding.erase(area)


func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("collect"):     
		player_sprite.play("collect")   
		for object in collectable_objects_colliding:
			if is_instance_valid(object):
				object.owner._on_collected()
				collectable_objects_colliding.erase(object)
