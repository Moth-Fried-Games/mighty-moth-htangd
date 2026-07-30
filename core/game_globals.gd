@tool
extends Node

var rng: RandomNumberGenerator = RandomNumberGenerator.new()

@export var game_settings_scene: PackedScene:
	set(value):
		if is_instance_valid(value):
			var value_instance: GameSettings = load(value.resource_path).instantiate()
			if value_instance is GameSettings:
				game_settings_scene = value
			else:
				print("Scene is not of type GameSettings")
		else:
			game_settings_scene = value
var game_settings: GameSettings = null
@export var game_data_scene: PackedScene:
	set(value):
		if is_instance_valid(value):
			var value_instance: GameData = load(value.resource_path).instantiate()
			if value_instance is GameData:
				game_data_scene = value
			else:
				print("Scene is not of type GameData")
		else:
			game_data_scene = value
var game_data: GameData = null
var game_events: GameEvents = GameEvents.new()
var audio_manager: AudioManager = AudioManager.new()

var game_dictionary: Dictionary = {
	"flag": {},
	"stat": {},
	"node": {},
	"resource":
	{"explosion": preload("uid://dfqffce3j7sd4"), "sparkle": preload("uid://b07opuye2di21")},
}


func _ready() -> void:
	if not Engine.is_editor_hint():
		process_mode = Node.PROCESS_MODE_ALWAYS
		randomize()
		rng.randomize()
		game_settings = game_settings_scene.instantiate()
		game_data = game_data_scene.instantiate()
		game_events.name = "GameEvents"
		audio_manager.name = "AudioManager"
		add_child(game_settings)
		add_child(game_data)
		add_child(game_events)
		add_child(audio_manager)
		game_settings.load_settings()
		game_data.load_data()
		audio_manager.load_audio()
