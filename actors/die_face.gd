extends Node3D

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

var face: StuffDieFace:
	set(v):
		if face == v: return
		face = v
		_refresh()

var pips: Dictionary[Enums.PIP_TYPE, int]:
	set(v):
		if pips == v: return
		pips = v
		_refresh()

@onready var sub_viewport: SubViewport = $SubViewport
@onready var pip_nodes: Array[Node] = []

func _ready() -> void:
	_refresh()

func _refresh():
	if not is_inside_tree():
		return
	
	sub_viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
	
	if face == null:
		for p in pip_nodes:
			p.queue_free()
		pip_nodes.clear()
		return
	if pips.size() == 0:
		for p in pip_nodes:
			p.hide()
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
			sub_viewport.add_child(pip)
		
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
