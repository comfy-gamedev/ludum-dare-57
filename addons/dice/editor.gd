@tool
extends VBoxContainer

const WIDGET = preload("res://addons/dice/widget.tscn")

@export var face: int

var die: StuffDie

@onready var lock_check_button: CheckButton = $HBoxContainer/LockCheckButton

func _ready() -> void:
	if EditorInterface.get_edited_scene_root() == self:
		return
	while die.faces.size() < 6:
		die.faces.append(StuffDieFace.new())
	for i in 6:
		if die.faces[i] == null:
			die.faces[i] = StuffDieFace.new()
	
	lock_check_button.button_pressed = die.faces[face].autolocking

func _on_lock_check_button_toggled(toggled_on: bool) -> void:
	die.faces[face].autolocking = toggled_on
	ResourceSaver.save(die)
