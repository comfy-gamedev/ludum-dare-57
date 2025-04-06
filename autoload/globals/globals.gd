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


## Reset all variables to their default state.
func reset():
	for prop_name in _defaults:
		set(prop_name, _defaults[prop_name])

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
