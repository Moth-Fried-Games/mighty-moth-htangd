@tool
extends Node
class_name GameSettings

@export var game_size: Vector2i = Vector2i(320, 180)
@export var stretch_mode: bool = false

# Graphics
@export var display_mode: DisplayServer.WindowMode = DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN
@export var vsync_mode: DisplayServer.VSyncMode = DisplayServer.VSYNC_DISABLED
@export_enum("Auto", "30", "60", "144", "240", "360", "Uncapped", "Custom")
var frame_rate_cap: int = 0
@export var custom_frame_rate_cap: int = 60
@export var show_fps: bool = false

# Audio
@export_range(0, 1) var master_volume: float = 0.5
@export_range(0, 1) var music_volume: float = 0.5
@export_range(0, 1) var sound_volume: float = 0.5
@export_range(0, 1) var ui_volume: float = 0.5

# Controls
@export_range(0.01, 1) var mouse_sensitivity: float = 0.5

var last_game_size: Vector2 = Vector2.ZERO


func _process(_delta: float) -> void:
	update_stretch_mode()


func update_stretch_mode() -> void:
	if stretch_mode:
		var current_viewport_size: Vector2 = get_window().size
		if last_game_size != current_viewport_size:
			last_game_size = current_viewport_size
			if last_game_size.x >= game_size.x and last_game_size.y >= game_size.y:
				get_window().content_scale_mode = Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
				get_window().content_scale_aspect = Window.CONTENT_SCALE_ASPECT_EXPAND
				#print("Normal Window")
			else:
				get_window().content_scale_mode = Window.CONTENT_SCALE_MODE_VIEWPORT
				get_window().content_scale_aspect = Window.CONTENT_SCALE_ASPECT_KEEP
				#print("Smaller Window")


func save_settings() -> void:
	var config: ConfigFile = ConfigFile.new()

	config.set_value("Graphics", "display_mode", display_mode)
	config.set_value("Graphics", "vsync_mode", vsync_mode)
	config.set_value("Graphics", "frame_rate_cap", frame_rate_cap)
	config.set_value("Graphics", "custom_frame_rate_cap", custom_frame_rate_cap)
	config.set_value("Graphics", "show_fps", show_fps)

	config.set_value("Audio", "master_volume", master_volume)
	config.set_value("Audio", "music_volume", music_volume)
	config.set_value("Audio", "sound_volume", sound_volume)
	config.set_value("Audio", "ui_volume", ui_volume)

	config.set_value("Controls", "mouse_sensitivity", mouse_sensitivity)

	config.save("user://settings.cfg")


func load_settings() -> void:
	var config: ConfigFile = ConfigFile.new()
	var err: Error = config.load("user://settings.cfg")
	if err == OK:
		display_mode = config.get_value("Graphics", "display_mode", display_mode)
		vsync_mode = config.get_value("Graphics", "vsync_mode", vsync_mode)
		frame_rate_cap = config.get_value("Graphics", "frame_rate_cap", frame_rate_cap)
		custom_frame_rate_cap = config.get_value(
			"Graphics", "custom_frame_rate_cap", custom_frame_rate_cap
		)
		show_fps = config.get_value("Graphics", "show_fps", show_fps)

		master_volume = config.get_value("Audio", "master_volume", master_volume)
		music_volume = config.get_value("Audio", "music_volume", music_volume)
		sound_volume = config.get_value("Audio", "sound_volume", sound_volume)
		ui_volume = config.get_value("Audio", "ui_volume", ui_volume)

		mouse_sensitivity = config.get_value("Controls", "mouse_sensitivity", mouse_sensitivity)

	update_display_mode(display_mode)
	update_vsync_mode(vsync_mode)
	update_frame_rate_cap(frame_rate_cap)
	update_master_volume(master_volume)
	update_music_volume(music_volume)
	update_sound_volume(sound_volume)
	update_ui_volume(ui_volume)


func update_display_mode(new_display_mode: DisplayServer.WindowMode) -> void:
	display_mode = new_display_mode
	DisplayServer.window_set_mode(display_mode)


func update_vsync_mode(new_vsync_mode: DisplayServer.VSyncMode) -> void:
	vsync_mode = new_vsync_mode
	DisplayServer.window_set_vsync_mode(vsync_mode)


func update_frame_rate_cap(new_frame_rate_cap: int) -> void:
	frame_rate_cap = new_frame_rate_cap
	match frame_rate_cap:
		0:
			var display_refresh: float = DisplayServer.screen_get_refresh_rate()
			Engine.set_max_fps(ceili(display_refresh))
		1:
			Engine.set_max_fps(30)
		2:
			Engine.set_max_fps(60)
		3:
			Engine.set_max_fps(144)
		4:
			Engine.set_max_fps(240)
		5:
			Engine.set_max_fps(360)
		6:
			Engine.set_max_fps(0)
		7:
			Engine.set_max_fps(custom_frame_rate_cap)


func update_show_fps(new_show_fps: bool) -> void:
	show_fps = new_show_fps


func update_master_volume(new_master_volume: float) -> void:
	master_volume = new_master_volume
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(master_volume))


func update_music_volume(new_music_volume: float) -> void:
	music_volume = new_music_volume
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(music_volume))


func update_sound_volume(new_sound_volume: float) -> void:
	sound_volume = new_sound_volume
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Sounds"), linear_to_db(sound_volume))


func update_ui_volume(new_ui_volume: float) -> void:
	ui_volume = new_ui_volume
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Ui"), linear_to_db(ui_volume))


func update_mouse_sensitivity(new_mouse_sensitivity: float) -> void:
	mouse_sensitivity = new_mouse_sensitivity
	mouse_sensitivity = clampf(mouse_sensitivity, 0.01, 1)
