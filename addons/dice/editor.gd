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
	for i in Enums.PIP_TYPE.values():
		if i not in Enums.PIP_TEXTURES:
			continue
		var w = WIDGET.instantiate()
		w.texture_rect.texture = Enums.PIP_TEXTURES[i]
		w.texture_rect.tooltip_text = Enums.PIP_TYPE.find_key(i)
		w.spin_box.value = die.faces[face].pips.get(i, 0)
		w.spin_box.value_changed.connect(
			func (v):
				die.faces[face].pips[i] = int(v)
				if v == 0:
					die.faces[face].pips.erase(i)
				ResourceSaver.save(die)
		)
		add_child(w)
	lock_check_button.button_pressed = die.faces[face].autolocking

func _on_lock_check_button_toggled(toggled_on: bool) -> void:
	die.faces[face].autolocking = toggled_on
	ResourceSaver.save(die)
