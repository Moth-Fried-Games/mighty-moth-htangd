extends Area2D
class_name PlayerHitBox

var punchble_objects_colliding : Array[Area2D]

func _ready() -> void:
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)
	
# Confirming the colliding entity is in the same lane as the player
func _is_in_same_lane(colliding_area: Area2D) -> bool:
	if colliding_area.owner is LaneEntity:
		return colliding_area.owner.current_lane == owner.current_lane
	return false

func _on_area_entered(area: Area2D) -> void:	
	if _is_in_same_lane(area) and area.is_in_group("MeleeHitBoxArea"):
		punchble_objects_colliding.append(area)

func _on_area_exited(area: Area2D) -> void:
	if punchble_objects_colliding.has(area) and area.is_in_group("MeleeHitBoxArea"):
		punchble_objects_colliding.erase(area)

func _physics_process(_delta: float) -> void:
	var isPunching: bool = owner.player_sprite.punching
	if isPunching:
		for object in punchble_objects_colliding:
			if is_instance_valid(object):
				object.owner._on_punched()
				punchble_objects_colliding.erase(object)
