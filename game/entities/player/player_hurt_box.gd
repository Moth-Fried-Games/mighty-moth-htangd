extends Area2D
class_name PlayerHurtBox

@onready var player_sprite: PlayerSprite = $"../PlayerSprite"

var is_deflecting : bool = false

func _ready() -> void:
	area_entered.connect(_on_area_entered)
	
# Confirming the colliding entity is in the same lane as the player
func _is_in_same_lane(colliding_area: Area2D) -> bool:
	if colliding_area.owner is LaneEntity:
		return colliding_area.owner.current_lane == owner.current_lane
	return false

func _on_area_entered(area: Area2D) -> void:
	if _is_in_same_lane(area):
		if area.is_in_group("HurtBoxArea"):
			area.owner._on_touching_player()
