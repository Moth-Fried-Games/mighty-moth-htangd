extends Area2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if has_overlapping_areas():
		if get_overlapping_areas().any(func(area) -> bool: return area.name == "ObstacleDespawnerLeft"):
			owner._on_walk_past_player()
		elif get_overlapping_areas().any(func(area) -> bool: return area.name == "ParryHurtBoxArea"):
			owner._on_deflected()
	return
