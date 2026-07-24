extends Node2D

@onready var dialog: Dialog = $Dialog


func _ready() -> void:
	GameUi.ui_transitions.toggle_transition(false)
