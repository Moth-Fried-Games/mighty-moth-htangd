extends Area2D
class_name ObstacleDespawner


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	area_entered.connect(_on_area_entered)

func _on_area_entered(area: Area2D) -> void:
	if area is LaneEntity:
		area._on_walk_past_player()
	else:
		area.owner._on_walk_past_player() # ObstacleDespawner._on_area_entered: Attempt to call function '_on_walk_past_player' in base 'null instance' on a null instance.
