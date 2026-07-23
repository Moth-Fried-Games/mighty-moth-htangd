extends CanvasLayer

@onready var tab_container: TabContainer = $Control/TabContainer

# Main Menu
@onready var main_start_button: Button = %MainStartButton
@onready var main_how_button: Button = %MainHowButton
@onready var main_settings_button: Button = %MainSettingsButton
@onready var main_credits_button: Button = %MainCreditsButton
@onready var main_quit_button: Button = %MainQuitButton

# How to Play
@onready var how_to_return_button: Button = %HowToReturnButton

# Settings
@onready var settings_master_h_slider: HSlider = %SettingsMasterHSlider
@onready var settings_master_label: Label = %SettingsMasterLabel
@onready var settings_music_h_slider: HSlider = %SettingsMusicHSlider
@onready var settings_music_label: Label = %SettingsMusicLabel
@onready var settings_sound_h_slider: HSlider = %SettingsSoundHSlider
@onready var settings_sound_label: Label = %SettingsSoundLabel
@onready var settings_display_option_button: OptionButton = %SettingsDisplayOptionButton
@onready var settings_v_sync_option_button: OptionButton = %SettingsVSyncOptionButton
@onready var settings_frame_cap_option_button: OptionButton = %SettingsFrameCapOptionButton
@onready var settings_frame_label_option_button: OptionButton = %SettingsFrameLabelOptionButton
@onready var settings_return_button: Button = %SettingsReturnButton

# Credits
@onready var credits_return_button: Button = %CreditsReturnButton
@onready var credits_rich_text_label: RichTextLabel = %CreditsRichTextLabel

var input_ready: bool = false


func _ready() -> void:
	load_settings()
	main_start_button.pressed.connect(change_to_game)
	main_quit_button.pressed.connect(quit_game)
	main_how_button.pressed.connect(howto_menu)
	main_settings_button.pressed.connect(settings_menu)
	main_credits_button.pressed.connect(credits_menu)
	how_to_return_button.pressed.connect(main_menu)
	settings_return_button.pressed.connect(main_menu)
	settings_master_h_slider.value_changed.connect(_on_master_value_changed)
	settings_music_h_slider.value_changed.connect(_on_music_value_changed)
	settings_sound_h_slider.value_changed.connect(_on_sound_value_changed)
	settings_display_option_button.item_selected.connect(_on_display_item_selected)
	settings_v_sync_option_button.item_selected.connect(_on_vsync_item_selected)
	settings_frame_cap_option_button.item_selected.connect(_on_framecap_item_selected)
	settings_frame_label_option_button.item_selected.connect(_on_framelabel_item_selected)
	credits_return_button.pressed.connect(main_menu)
	credits_rich_text_label.meta_clicked.connect(credits_click_link)
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	GameUi.ui_transitions.toggle_transition(false)
	if not GameGlobals.audio_manager.persistent_audio.has("music_menu"):
		GameGlobals.audio_manager.create_persistent_audio("music_menu")
	tab_container.current_tab = 0


func _input(_event: InputEvent) -> void:
	if Input.is_anything_pressed() and tab_container.current_tab == 0:
		input_ready = true
		main_menu()


func main_menu() -> void:
	GameGlobals.audio_manager.create_audio("sound_menu_click")
	tab_container.current_tab = 1


func howto_menu() -> void:
	GameGlobals.audio_manager.create_audio("sound_menu_click")
	tab_container.current_tab = 2


func settings_menu() -> void:
	GameGlobals.audio_manager.create_audio("sound_menu_click")
	tab_container.current_tab = 3


func credits_menu() -> void:
	GameGlobals.audio_manager.create_audio("sound_menu_click")
	tab_container.current_tab = 4


func credits_click_link(meta: Variant) -> void:
	if input_ready:
		GameGlobals.audio_manager.create_audio("sound_menu_click")
		OS.shell_open(meta)


func change_to_game() -> void:
	if input_ready:
		input_ready = false
		GameGlobals.audio_manager.create_audio("sound_menu_click")
		GameGlobals.audio_manager.fade_persistent_audio_out_and_destroy("music_menu", 1)
		GameUi.ui_transitions.change_scene_with_loading(GameGlobals.lab_scene)


func quit_game() -> void:
	get_tree().quit()


func load_settings() -> void:
	settings_master_h_slider.value = (GameGlobals.game_settings.master_volume * 100)
	settings_master_label.text = str("%d" % [GameGlobals.game_settings.master_volume * 100])
	settings_music_h_slider.value = (GameGlobals.game_settings.music_volume * 100)
	settings_music_label.text = str("%d" % [GameGlobals.game_settings.music_volume * 100])
	settings_sound_h_slider.value = (GameGlobals.game_settings.sound_volume * 100)
	settings_sound_label.text = str("%d" % [GameGlobals.game_settings.sound_volume * 100])
	match GameGlobals.game_settings.display_mode:
		DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN:
			settings_display_option_button.selected = 0
		DisplayServer.WINDOW_MODE_WINDOWED:
			settings_display_option_button.selected = 1
	match GameGlobals.game_settings.vsync_mode:
		DisplayServer.VSYNC_DISABLED:
			settings_v_sync_option_button.selected = 0
		DisplayServer.VSYNC_ENABLED:
			settings_v_sync_option_button.selected = 1
		DisplayServer.VSYNC_ADAPTIVE:
			settings_v_sync_option_button.selected = 2
		DisplayServer.VSYNC_MAILBOX:
			settings_v_sync_option_button.selected = 3
	match GameGlobals.game_settings.frame_rate_cap:
		0:
			settings_frame_cap_option_button.selected = 0
		1:
			settings_frame_cap_option_button.selected = 1
		2:
			settings_frame_cap_option_button.selected = 2
		3:
			settings_frame_cap_option_button.selected = 3
	if GameGlobals.game_settings.show_fps:
		settings_frame_label_option_button.selected = 1
	else:
		settings_frame_label_option_button.selected = 0


func _on_master_value_changed(value: float) -> void:
	GameGlobals.audio_manager.create_audio("sound_menu_click")
	settings_master_label.text = str("%d" % [value])
	GameGlobals.game_settings.update_master_volume(value / 100)


func _on_music_value_changed(value: float) -> void:
	GameGlobals.audio_manager.create_audio("sound_menu_click")
	settings_music_label.text = str("%d" % [value])
	GameGlobals.game_settings.update_music_volume(value / 100)


func _on_sound_value_changed(value: float) -> void:
	GameGlobals.audio_manager.create_audio("sound_menu_click")
	settings_sound_label.text = str("%d" % [value])
	GameGlobals.game_settings.update_sound_volume(value / 100)


func _on_display_item_selected(index: int) -> void:
	GameGlobals.audio_manager.create_audio("sound_menu_click")
	match index:
		0:
			GameGlobals.game_settings.update_display_mode(
				DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN
			)
		1:
			GameGlobals.game_settings.update_display_mode(DisplayServer.WINDOW_MODE_WINDOWED)


func _on_vsync_item_selected(index: int) -> void:
	GameGlobals.audio_manager.create_audio("sound_menu_click")
	GameGlobals.game_settings.update_vsync_mode(index)


func _on_framecap_item_selected(index: int) -> void:
	GameGlobals.audio_manager.create_audio("sound_menu_click")
	GameGlobals.game_settings.update_frame_rate_cap(index)


func _on_framelabel_item_selected(index: int) -> void:
	GameGlobals.audio_manager.create_audio("sound_menu_click")
	GameGlobals.game_settings.update_show_fps(index)
