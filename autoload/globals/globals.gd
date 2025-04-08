extends Node
## An empty global variable bag with a togglable debug overlay that displays all variables.
##
## Designed to hold simple global variables.
## A bad pattern, but in a game jam, sometimes you just need to get it done.
##
## Displays a debug overlay when the user hits the F1 key.
## All variables are displayed automatically.


## Emitted when any variable changes.
signal changed(prop_name: StringName)

## Example variable.
var player_stats: PlayerStats = null:
	set(v):
		if player_stats == v: return
		player_stats = v
		_notify_changed(&"player_stats")

var player_nav_event:String = ""

var act = 0

## Reset all variables to their default state.
func reset():
	for prop_name in _defaults:
		set(prop_name, _defaults[prop_name])
	
	player_stats = PlayerStats.new()
	player_stats.equipment = [
		preload("res://assets/items/punch.tres"),
		preload("res://assets/items/block.tres"),
	]
	player_stats.initial_mana = 3
	player_stats.initial_rerolls = 1

var available_equipment = {
	Enums.ITEMS.LEAD_PIPE : preload("res://assets/items/lead_pipe.tres"),
	Enums.ITEMS.SLIMY_LEAD_PIPE : preload("res://assets/items/slimy_lead_pipe.tres"),
	Enums.ITEMS.PIPE_WITH_NAIL : preload("res://assets/items/lead_pipe_with_nail.tres"),
	Enums.ITEMS.BOARD : preload("res://assets/items/board.tres"),
	Enums.ITEMS.DAGGER : preload("res://assets/items/dagger.tres"),
	Enums.ITEMS.POISON_DAGGER : preload("res://assets/items/poison_dagger.tres"),
	Enums.ITEMS.MANHOLE_COVER : preload("res://assets/items/manhole_cover.tres"),
	Enums.ITEMS.SLEDGEHAMMER : preload("res://assets/items/sledgehammer.tres"),
	Enums.ITEMS.GLASS_BOTTLE : preload("res://assets/items/glass bottle.tres"),
	Enums.ITEMS.HAMMER : preload("res://assets/items/hammer.tres"),
	Enums.ITEMS.SHIV : preload("res://assets/items/shiv.tres"),
	Enums.ITEMS.PIPE_WRENCH : preload("res://assets/items/pipe_wrench.tres"),
	Enums.ITEMS.PADDLE : preload("res://assets/items/paddle.tres"),
	Enums.ITEMS.Vitamins : preload("res://assets/items/vitamins.tres"),
	Enums.ITEMS.EMPTY_POISON_BOTTLE : preload("res://assets/items/empty_bottle_of_poison.tres"),
	#Enums.ITEMS.FULL_BEER_BOTTLE : preload("res://assets/items/bee.tres"),
	#Enums.ITEMS.PAIR_OF_SHOES : preload("res://assets/items/sh.tres"),
	#Enums.ITEMS.WARM_EGG : preload("res://assets/items/wa.tres"),
	#Enums.ITEMS.PACK_OF_CDS : preload("res://assets/items/paddle.tres"),
	#Enums.ITEMS.BUCKET_OF_SLIME : preload("res://assets/items/paddle.tres"),
	#Enums.ITEMS.FISHING_ROD : preload("res://assets/items/paddle.tres"),
	#Enums.ITEMS.BAG_OF_PENNIES : preload("res://assets/items/paddle.tres"),
	#Enums.ITEMS.REALLY_LONG_SHOELACE : preload("res://assets/items/paddle.tres"),
	#Enums.ITEMS.GLASSES : preload("res://assets/items/paddle.tres"),
	#Enums.ITEMS.TEMPORARY_TATTOO : preload("res://assets/items/paddle.tres"),
	Enums.ITEMS.TRAFFIC_CONE_HAT : preload("res://assets/items/traffic_cone.tres"),
	Enums.ITEMS.ARM_WARMERS : preload("res://assets/items/arm_warmers.tres"),
	Enums.ITEMS.TRASH_CAN_LID : preload("res://assets/items/trash_can_lid.tres"),
	Enums.ITEMS.CLEAN_SOCK : preload("res://assets/items/clean_sock.tres"),
	Enums.ITEMS.DIRTY_SOCK : preload("res://assets/items/dirty_sock.tres"),
	Enums.ITEMS.DIVING_HELMET : preload("res://assets/items/diving_helmet.tres"),
	Enums.ITEMS.HARD_HAT : preload("res://assets/items/hardhat.tres"),
	Enums.ITEMS.HI_VIS_VEST : preload("res://assets/items/hi_vis_vest.tres"),
	Enums.ITEMS.OVERALLS : preload("res://assets/items/overalls.tres"),
	Enums.ITEMS.WET_GLOVES : preload("res://assets/items/wet_gloves.tres"),
	Enums.ITEMS.BLANK_DIE : preload("res://assets/items/blank.tres"),
	Enums.ITEMS.MANA_BALL : preload("res://assets/items/mana_ball.tres"),
}

func _ready() -> void:
	player_stats = PlayerStats.new()
	player_stats.equipment = [
		preload("res://assets/items/punch.tres"),
		preload("res://assets/items/block.tres"),
	]
	player_stats.initial_mana = 3
	player_stats.initial_rerolls = 1

#region Plumbing
var _defaults: Dictionary[StringName, Variant] = {}

func _notify_changed(prop_name: StringName) -> void:
	changed.emit(prop_name)

func _init() -> void:
	for prop in get_property_list():
		if prop.usage & PROPERTY_USAGE_SCRIPT_VARIABLE:
			_defaults[prop.name] = get(prop.name)
#endregion

#region Debug overlay
var _overlay
func _unhandled_key_input(event: InputEvent) -> void:
	if event.pressed:
		match event.physical_keycode:
			KEY_F1:
				if not _overlay:
					_overlay = load("res://autoload/globals/globals_overlay.tscn").instantiate()
					get_parent().add_child(_overlay)
				else:
					_overlay.visible = not _overlay.visible
#endregion
