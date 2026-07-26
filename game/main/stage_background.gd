@tool
class_name StageBackground
extends Node2D

@onready var parallax_1: Parallax2D = $Parallax1
@onready var parallax_2: Parallax2D = $Parallax2
@onready var parallax_3: Parallax2D = $Parallax3
@onready var parallax_4: Parallax2D = $Parallax4
@onready var planets: Array[Sprite2D] = [$Planet1, $Planet2, $Planet3, $Planet4]
@onready var space_station_win: Node2D = $SpaceStationWin
@onready var space_station_lose: AnimatedSprite2D = $SpaceStationLose
@onready var win_animation_player: AnimationPlayer = $SpaceStationWin/WinAnimationPlayer
@onready var space_station_marker: Marker2D = %SpaceStationMarker

@export var scroll_speed: float = 100
@export var modifier_1: float = 1
@export var modifier_2: float = 0.25
@export var modifier_3: float = 0.5
@export var modifier_4: float = 0.75

var speed_modifier: float = 1

var show_win_station: bool = false
var show_lose_station: bool = false
var scrolling_planet: Node2D = null
var scrolling_planet_size: float = 0

var planet_sizes: Array[float] = [203, 114, 41, 85]


func _ready() -> void:
	if not Engine.is_editor_hint():
		win_animation_player.animation_finished.connect(_on_win_animation_finished)
		space_station_lose.animation_finished.connect(_on_lose_animation_finished)
	adjust_space_stations()
	for planet in planets.size():
		planets[planet].position.x = -planet_sizes[planet]
	await get_tree().create_timer(1).timeout
	if not GameGlobals.audio_manager.persistent_audio.has("music_game"):
		GameGlobals.audio_manager.create_persistent_audio("music_game")
	#await get_tree().create_timer(1).timeout
	#win()
	#lose()


func _process(delta: float) -> void:
	scroll_parallax(delta)
	scroll_planets(delta)
	adjust_space_stations()


func scroll_planet(planet: Node2D, size: float, delta: float) -> bool:
	var finished: bool = false
	planet.position.x -= scroll_speed * speed_modifier * modifier_1 * delta
	if planet.position.x <= -size:
		finished = true
	return finished


func scroll_planets(delta: float) -> void:
	var viewport_size: Vector2 = get_viewport_rect().size
	if not is_instance_valid(scrolling_planet):
		scrolling_planet = planets.pick_random()
		scrolling_planet_size = planet_sizes[planets.find(scrolling_planet)] * 2
		scrolling_planet.position.x = viewport_size.x + scrolling_planet_size
		scrolling_planet.reset_physics_interpolation()
	if is_instance_valid(scrolling_planet):
		scrolling_planet.position.x -= scroll_speed * speed_modifier * modifier_1 * delta
		if scrolling_planet.position.x <= -scrolling_planet_size:
			scrolling_planet = null


func scroll_parallax(delta: float) -> void:
	parallax_2.scroll_offset.x -= scroll_speed * speed_modifier * modifier_2 * delta
	parallax_2.scroll_offset.x = wrapf(parallax_2.scroll_offset.x, -1280, 1280)
	parallax_3.scroll_offset.x -= scroll_speed * speed_modifier * modifier_3 * delta
	parallax_3.scroll_offset.x = wrapf(parallax_3.scroll_offset.x, -1280, 1280)
	parallax_4.scroll_offset.x -= scroll_speed * speed_modifier * modifier_4 * delta
	parallax_4.scroll_offset.x = wrapf(parallax_4.scroll_offset.x, -1280, 1280)


func adjust_space_stations() -> void:
	var viewport_size: Vector2 = get_viewport_rect().size
	var viewport_offset: float = viewport_size.x + (245 * 2)

	if not show_win_station:
		if space_station_win.position.x != viewport_offset:
			space_station_win.position.x = viewport_offset
	if not show_lose_station:
		if space_station_lose.position.x != viewport_offset:
			space_station_lose.position.x = viewport_offset


func win() -> void:
	show_win_station = true
	var viewport_size: Vector2 = get_viewport_rect().size
	var viewport_offset: float = viewport_size.x - (245)
	var win_tween: Tween = create_tween().set_parallel()
	win_tween.finished.connect(_on_win_tween_finished)
	win_tween.tween_property(space_station_win, "position:x", viewport_offset, 5)
	win_tween.tween_property(self, "speed_modifier", 0, 5)
	GameGlobals.audio_manager.fade_persistent_audio_out_and_destroy("music_game", 1)


func _on_win_tween_finished() -> void:
	var player: Player = null
	if GameGlobals.game_dictionary["node"].has("player"):
		player = GameGlobals.game_dictionary["node"]["player"]
	if is_instance_valid(player):
		player.cutscene = true
		var player_tween: Tween = create_tween().set_parallel()
		player_tween.finished.connect(_on_player_tween_finished)
		player_tween.tween_property(
			player, "global_position", space_station_marker.global_position, 1
		)
		player_tween.tween_property(player, "scale", Vector2.ZERO, 1)


func _on_player_tween_finished() -> void:
	await get_tree().create_timer(1).timeout
	win_animation_player.play("fade_in")


func _on_win_animation_finished(anim_name: String) -> void:
	if anim_name == "fade_in":
		await get_tree().create_timer(1).timeout
		win_animation_player.play("explode")
	if anim_name == "explode":
		var main_ui: MainUI = null
		if GameGlobals.game_dictionary["node"].has("main_ui"):
			main_ui = GameGlobals.game_dictionary["node"]["main_ui"]
		if is_instance_valid(main_ui):
			main_ui.win()


func lose() -> void:
	show_lose_station = true
	var viewport_size: Vector2 = get_viewport_rect().size
	var viewport_offset: float = viewport_size.x - (245)
	var lose_tween: Tween = create_tween().set_parallel()
	lose_tween.finished.connect(_on_lose_tween_finished)
	lose_tween.tween_property(space_station_lose, "position:x", viewport_offset, 5)
	lose_tween.tween_property(self, "speed_modifier", 0, 5)
	GameGlobals.audio_manager.fade_persistent_audio_out_and_destroy("music_game", 1)


func _on_lose_tween_finished() -> void:
	await get_tree().create_timer(1).timeout
	space_station_lose.play()


func _on_lose_animation_finished() -> void:
	var main_ui: MainUI = null
	if GameGlobals.game_dictionary["node"].has("main_ui"):
		main_ui = GameGlobals.game_dictionary["node"]["main_ui"]
	if is_instance_valid(main_ui):
		main_ui.lose()
