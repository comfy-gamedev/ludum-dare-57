extends Node3D

var pips: Dictionary[Enums.PIP_TYPE, int]:
	set(v):
		if pips == v: return
		pips = v
		_refresh()

@onready var sub_viewport: SubViewport = $SubViewport
@onready var die_face_control: TextureRect = $SubViewport/DieFaceControl

func _ready() -> void:
	_refresh()

func _refresh():
	if not is_inside_tree():
		return
	
	die_face_control.pips = pips


func _on_die_face_control_refresh() -> void:
	if not is_inside_tree() or not sub_viewport:
		return
	
	sub_viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
