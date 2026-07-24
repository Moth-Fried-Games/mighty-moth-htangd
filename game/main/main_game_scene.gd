extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameUi.ui_transitions.toggle_transition(false)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
