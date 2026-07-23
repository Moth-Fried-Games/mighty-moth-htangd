@tool
extends CanvasLayer

@export var ui_frame_rate_scene: PackedScene:
	set(value):
		if is_instance_valid(value):
			var value_instance = load(value.resource_path).instantiate()
			if value_instance is UIFrameRate:
				ui_frame_rate_scene = value
			else:
				print("Scene is not of type UIFrameRate")
		else:
			ui_frame_rate_scene = value
var ui_frame_rate: UIFrameRate = null
@export var ui_transitions_scene: PackedScene:
	set(value):
		if is_instance_valid(value):
			var value_instance = load(value.resource_path).instantiate()
			if value_instance is UITransitions:
				ui_transitions_scene = value
			else:
				print("Scene is not of type UITransitions")
		else:
			ui_frame_rate_scene = value
var ui_transitions: UITransitions = null

func _ready() -> void:
	if not Engine.is_editor_hint():
		layer = 128
		process_mode = Node.PROCESS_MODE_ALWAYS

		ui_frame_rate = ui_frame_rate_scene.instantiate()
		ui_transitions = ui_transitions_scene.instantiate()

		ui_frame_rate.layer = 126
		add_child(ui_frame_rate)

		ui_transitions.layer = 98
		add_child(ui_transitions)
