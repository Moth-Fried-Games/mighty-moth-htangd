class_name SuperMeterHandler
extends Node

const on_punch_meter_gain: int = 1
const on_deflect_meter_gain: int = 2
const on_collect_meter_gain: int = 3

var super_level: int = 0
var super_meter: float = 0
var combo_count: int = 0
var combo_multiplier: float = 0

const super_level_max: int = 3
const super_meter_max: float = 100
const combo_increment_on_punch: int = 1
const combo_increment_on_deflect: int = 2
const combo_multiplier_increment_threshold: int = 5
const combo_multiplier_increment_value: float = 5
const combo_multiplier_maximum: float = 10

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

	
# Gives meter on a punch
func on_successful_punch() -> void:
	increment_combo(combo_increment_on_punch)
	apply_meter_gain(on_punch_meter_gain)
	return
	
# Gives meter on a deflect
func on_successful_deflect() -> void:
	increment_combo(combo_increment_on_deflect)
	apply_meter_gain(on_deflect_meter_gain)
	return
	
# Gives meter on a collect
func on_successful_collect() -> void:
	apply_meter_gain(on_collect_meter_gain)
	return
	
# Maths how much meter the player gets, accounting for their combo multiplier
func calculate_meter_gain_value(base_gain_value: float) -> float:
	var multiplier: float = combo_multiplier
	if multiplier <= 0:
		multiplier = 1
	#var combo_bonus: float = (1.00 + (0.01 * combo_multiplier))
	print("Combo multiplier is currently...... " + str(multiplier))
	return base_gain_value * multiplier
	
# Increases combo counter and, if applicable, combo multiplier
func increment_combo(increment_value: int) -> void:
	var previous_combo_increment_threshold: int = combo_count / combo_multiplier_increment_threshold
	
	combo_count += increment_value
	if combo_multiplier < combo_multiplier_maximum and combo_count / combo_multiplier_increment_threshold > previous_combo_increment_threshold:
		combo_multiplier += combo_multiplier_increment_value
	return

# Applies meter gain, adjusting the super level as needed
func apply_meter_gain(gain_value: float) -> void:
	var adjusted_gain_value: float = calculate_meter_gain_value(gain_value)
	
	if super_level < super_level_max:
		super_meter += adjusted_gain_value
		
		if super_meter >= super_meter_max:
			super_level += 1
			if super_level < super_level_max:
				super_meter -= super_meter_max
			else:
				super_meter = super_meter_max
				
	return

# Removes all super levels, adjusting for the level-3 specific meter display as needed
func expend_super_meter() -> void:
	if super_level >= super_level_max:
		super_meter = 0
	super_level = 0
	return

# Breaks the player's combo count and multiplier
func on_combo_break() -> void:
	combo_count = 0
	combo_multiplier = 0
	return
