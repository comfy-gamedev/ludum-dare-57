@tool
extends TextureRect

signal refresh()

const DIE_FACE_PIP = preload("res://actors/die_face_pip.tscn")
const MAX_PIPS = 9
const CENTER_POSITION = Vector2(16, 16)
const POSITIONS = [
	Vector2(0, 0),
	Vector2(32, 32),
	Vector2(0, 32),
	Vector2(32, 0),
	Vector2(0, 16),
	Vector2(32, 16),
	Vector2(16, 0),
	Vector2(16, 32),
]

var pips: Dictionary[Enums.PIP_TYPE, int]:
	set(v):
		if pips == v: return
		pips = v
		_refresh()

@onready var pip_nodes: Array[Node] = []

func _ready() -> void:
	_refresh()

func _refresh():
	if Engine.is_editor_hint() and EditorInterface.get_edited_scene_root() and EditorInterface.get_edited_scene_root().is_ancestor_of(self):
		return
	
	refresh.emit()
	
	if not is_inside_tree():
		return
	
	var pip_list = PipUtils.deconstruct_pips(pips, MAX_PIPS)
	
	var num_pips = mini(MAX_PIPS, pip_list.size())
	var first = pip_list.size() - num_pips
	
	for i in range(first, pip_list.size()):
		var p = pip_list[i]
		
		var pip: TextureRect
		if i - first < pip_nodes.size():
			pip = pip_nodes[i]
		else:
			pip = DIE_FACE_PIP.instantiate()
			pip_nodes.append(pip)
			add_child(pip)
		
		pip.show()
		
		if i == pip_list.size() - 1 and i % 2 == 0:
			pip.position = CENTER_POSITION
		else:
			pip.position = POSITIONS[i - first]
		
		pip.texture = Enums.PIP_TEXTURES[p.type]
		
		if p.count > 1:
			pip.label.text = str(p.count)
			pip.label.show()
		else:
			pip.label.hide()
			pip.label.text = ""
	
	for i in range(pip_list.size(), pip_nodes.size()):
		pip_nodes[i].hide()
