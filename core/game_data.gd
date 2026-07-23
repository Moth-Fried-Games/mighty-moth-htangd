@tool
extends Node
class_name GameData

@export_tool_button("Update Resources") var update_resources_button = update_resources
@export_category("Configuration")
@export_dir var configuration_directory: String = "res://game/configuration"
@export var configuration_dictionary = {}
@export_category("Audio")
@export_dir var audio_directory: String = "res://assets/audio"
@export var audio_resources: Array[AudioSettings] = []

var resource_dictionary: Dictionary = {}


func update_resources() -> void:
	# Populate Configuration
	configuration_dictionary.clear()
	if DirAccess.dir_exists_absolute(configuration_directory):
		for configuration_setting in GameUtils.get_all_files(configuration_directory, "tres"):
			var configuration_setting_resource: Resource = load(configuration_setting)
			var configuration_name = configuration_setting.get_basename().get_file()
			configuration_dictionary[configuration_name] = configuration_setting_resource
		print("Updated Configuration Resources")
	else:
		print("Configuration Directory does not exist.")
	# Populate Audio
	audio_resources.clear()
	if DirAccess.dir_exists_absolute(audio_directory):
		for audio_setting in GameUtils.get_all_files(audio_directory, "tres"):
			var audio_setting_resource: AudioSettings = load(audio_setting)
			audio_setting_resource.audio_name = audio_setting.get_basename().get_file()
			audio_resources.append(audio_setting_resource)
		print("Updated Audio Resources")
	else:
		print("Audio Directory does not exist.")


func load_data() -> void:
	pass


func get_threaded_resource(resource_name: String) -> Resource:
	if resource_dictionary.has(resource_name):
		if is_instance_valid(resource_dictionary[resource_name]):
			return resource_dictionary[resource_name]

	var is_resource_loaded: ResourceLoader.ThreadLoadStatus = (
		ResourceLoader.load_threaded_get_status(resource_name)
	)

	if is_resource_loaded != ResourceLoader.THREAD_LOAD_LOADED:
		ResourceLoader.load_threaded_request(resource_name)
		while is_resource_loaded != ResourceLoader.THREAD_LOAD_LOADED:
			await get_tree().process_frame
			is_resource_loaded = ResourceLoader.load_threaded_get_status(resource_name)

	if is_resource_loaded == ResourceLoader.THREAD_LOAD_LOADED:
		resource_dictionary[resource_name] = ResourceLoader.load_threaded_get(resource_name)
		return resource_dictionary[resource_name]
	else:
		return null
