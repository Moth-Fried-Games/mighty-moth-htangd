extends Area2D
class_name PlayerHitBox

var punchble_objects_colliding : Array[Area2D]

func _ready() -> void:
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)

func _on_area_entered(area: Area2D) -> void:	
	if area.is_in_group("MeleeHitBoxArea"):
		punchble_objects_colliding.append(area)

func _on_area_exited(area: Area2D) -> void:
	if area.is_in_group("MeleeHitBoxArea"):
		punchble_objects_colliding.erase(area)

func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("punch"):
		#print("punch pressed")
		for object in punchble_objects_colliding:
			if is_instance_valid(object):
				object.owner._on_punched()
			punchble_objects_colliding.erase(object)
