@tool
extends EditorPlugin

const SCREEN = preload("res://addons/dice/screen.tscn")

var screen: Node

func _enter_tree() -> void:
	screen = SCREEN.instantiate()
	EditorInterface.get_editor_main_screen().add_child(screen)
	_make_visible(false)

func _exit_tree() -> void:
	screen.queue_free()

func _has_main_screen():
	return true

func _get_plugin_name():
	return "Dice"


func _get_plugin_icon():
	return EditorInterface.get_editor_theme().get_icon("Node", "EditorIcons")

func _make_visible(visible):
	if screen:
		screen.visible = visible

