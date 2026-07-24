@tool
class_name UIDialog
extends PanelContainer

@onready var rich_text_label: RichTextLabel = $MarginContainer/RichTextLabel

var ui_inputs: Array[String] = []
var text: String = ""
var original_text: String = ""
var clean_text: String = ""

var hide_tween: Tween = null
var hiding: bool = false
var showing: bool = false
var reset_text: bool = false

var text_wait_splits: Array[String] = []
var text_wait_times: Array[float] = []
var text_tween: Tween = null
var text_index: int = 0
var text_character_ratio: float = 0
var text_typing: bool = false
var text_finished: bool = true

signal typing_finished


func clear() -> void:
	message("")


func message(new_text: String) -> void:
	size.y = 0
	ui_inputs = []
	text = new_text
	original_text = new_text
	split_waits()
	type_text()


func message_input(new_text: String) -> void:
	size.y = 0
	text = new_text
	original_text = new_text
	#text = str(text, "[center]***************[/center]\n")
	update_inputs()
	split_waits()
	type_text()


func update_inputs() -> void:
	for ui_input in ui_inputs:
		var input_label: String = ui_input.split(" ")[0]
		var input_name: String = ui_input.split(" ")[1]
		var input_texture_path: String = input_path(input_label)
		var input_tag: String = img_tag(input_texture_path)
		text = str(text, "[font_size=24][right]", input_name, " ", input_tag, "[/right]\n")


func img_tag(image_path: String) -> String:
	var tag_text: String = str("[img=24x24,center,center]", image_path, "[/img]")
	return tag_text


func input_path(input_label: String) -> String:
	var input_texture_path: String = ""
	if GameConstants.InputIcon.has(input_label):
		var input_texture: ControllerIconTexture = GameConstants.InputIcon[input_label]
		input_texture_path = input_texture.resource_path
	return input_texture_path


func split_waits() -> void:
	text_wait_splits.clear()
	text_wait_times.clear()
	var regex: RegEx = RegEx.new()
	var wait_open: Array[String] = []
	var wait_close: Array[String] = []
	regex.compile("\\[\\/?(?:wait){1,}.*?]")
	var results: Array[RegExMatch] = regex.search_all(text)
	if results.is_empty():
		clean_text = text
		return
	#print("BBCode Wait Matches: ")
	for result in results:
		var result_string: String = result.get_string()
		if result_string.begins_with("[w"):
			wait_open.append(result_string)
		if result_string.begins_with("[/w"):
			wait_close.append(result_string)
		#print(result_string)
	#if wait_open.size() != wait_close.size():
	#print("WARNING: BBCode [wait] tag missing corresponding [/wait].")
	if not wait_open.is_empty():
		var open_index: int = 0
		var close_index: int = 0
		open_index = text.find(wait_open[0])
		#Get text before the first wait tag
		if open_index > 0:
			text_wait_splits.append(text.substr(0, open_index))
			text_wait_times.append(0)
		# Get the text between each block of wait tags.
		for w in wait_open.size():
			open_index = text.find(wait_open[w], close_index)
			close_index = text.find(wait_close[w], open_index)
			text_wait_splits.append(
				text.substr(
					open_index + wait_open[w].length(),
					close_index - open_index - wait_open[w].length()
				)
			)
			#Get any specified timer for each wait tag, default to 1 if none.
			var timer_index: int = wait_open[w].find("=")
			if timer_index < 0:
				text_wait_times.append(1)
			else:
				var ending_index: int = wait_open[w].find("]")
				var timer_string: String = wait_open[w].substr(
					timer_index + 1, ending_index - timer_index + 1
				)
				text_wait_times.append(timer_string.to_float())
			#Get any text between blocks of wait tags.
			if w < wait_open.size() - 1:
				var next_open_index: int = text.find(wait_open[w + 1], close_index)
				if (close_index - open_index - wait_open[w].length()) != next_open_index:
					text_wait_splits.append(
						text.substr(
							close_index + wait_close[w].length(),
							next_open_index - close_index - wait_close[w].length()
						)
					)
					text_wait_times.append(0)
		#Get text after the last wait tag
		if close_index + wait_close[wait_close.size() - 1].length() < text.length():
			text_wait_splits.append(
				text.substr(
					close_index + wait_close[wait_close.size() - 1].length(),
					text.length() - close_index + wait_close[wait_close.size() - 1].length()
				)
			)
			text_wait_times.append(0)
		clean_text = "".join(text_wait_splits)
		#print('Original Text: \n"', text, '"')
		#print("Wait Split Text: \n", text_wait_splits)
		#print("Wait Split Times: \n", text_wait_times)
		#print("Clean Text: \n", clean_text)


func toggle_hide_tween(toggle: bool) -> void:
	if toggle and not showing:
		hiding = false
		showing = true
		if is_instance_valid(hide_tween):
			hide_tween.kill()
		hide_tween = create_tween().set_parallel()
		hide_tween.finished.connect(func() -> void: hiding = false)
		hide_tween.finished.connect(func() -> void: showing = false)
		hide_tween.tween_property(self, "modulate:a", 1, 0.25)
	elif not toggle and not hiding:
		hiding = true
		showing = false
		if is_instance_valid(hide_tween):
			hide_tween.kill()
		hide_tween = create_tween().set_parallel()
		hide_tween.finished.connect(func() -> void: hiding = false)
		hide_tween.finished.connect(func() -> void: showing = false)
		if reset_text:
			hide_tween.finished.connect(func() -> void: clear())
			hide_tween.finished.connect(func() -> void: reset_text = false)
		hide_tween.tween_property(self, "modulate:a", 0, 0.25)


func type_text() -> void:
	if rich_text_label.text != clean_text:
		rich_text_label.text = clean_text
	if text_wait_splits.is_empty():
		print("Wait Splits Empty")
		rich_text_label.visible_ratio = 1
		text_typing = false
		text_finished = true
		typing_finished.emit()
	else:
		text_typing = true
		text_index = 0
		text_character_ratio = 1.0 / rich_text_label.get_total_character_count()
		## TODO REMOVE BBCODE FROM TEXT WAIT SPLITS
		rich_text_label.visible_ratio = 0
		type_tween()


func type_tween() -> void:
	if text_index >= text_wait_splits.size():
		text_typing = false
		text_finished = true
		typing_finished.emit()
		return
	var tween_length: int = text_wait_splits[text_index].length()
	var tween_ratio: float = text_character_ratio * tween_length
	var tween_time: float = text_wait_times[text_index]
	var tween_next: float = rich_text_label.visible_ratio + tween_ratio
	if text_wait_times[text_index] == 0:
		rich_text_label.visible_ratio = tween_next
		text_index += 1
		type_tween()
	else:
		if is_instance_valid(text_tween):
			text_tween.kill()
		text_tween = create_tween().set_parallel()
		text_tween.finished.connect(type_tween)
		text_tween.tween_property(rich_text_label, "visible_ratio", tween_next, tween_time)
		text_index += 1


func finish_typing() -> void:
	if is_instance_valid(text_tween):
		text_tween.kill()
	rich_text_label.visible_ratio = 1
	text_index = text_wait_splits.size()
	type_tween()
