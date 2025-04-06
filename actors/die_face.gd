extends Node3D

const PIP_TEXTURES = {
	Enums.PIP_TYPE.ATTACK: preload("res://assets/textures/pip_attack.png"),
	Enums.PIP_TYPE.DEFEND: preload("res://assets/textures/pip_shield.png"),
}

const POSITIONS = [
	Vector3(-0.25, 0.25, 0.0),
	Vector3(0.25, -0.25, 0.0),
	Vector3(0.25, 0.25, 0.0),
	Vector3(-0.25, -0.25, 0.0),
]

@export var face: StuffDieFace:
	set(v):
		if face == v: return
		face = v
		_refresh()

var pip_meshes: Array[Node3D]

@onready var pip_template: MeshInstance3D = $PipTemplate

func _ready() -> void:
	_refresh()

func _refresh():
	if not is_inside_tree():
		return
	for n in pip_meshes:
		n.queue_free()
	pip_meshes = []
	if face == null:
		return
	var pip_list = []
	for p in face.pips:
		if face.pips[p] > 0:
			pip_list.push_back({ type = p, count = face.pips[p] })
	pip_list.sort_custom(func (a, b): return a.count > b.count)
	for i in pip_list.size():
		var p = pip_list[i]
		if p.count > 4 - pip_meshes.size() - (pip_list.size() - i - 1):
			var m: MeshInstance3D = pip_template.duplicate()
			var mat: StandardMaterial3D = m.material_override.duplicate()
			m.material_override = mat
			mat.albedo_texture = PIP_TEXTURES[p.type]
			var label = m.get_node("Label3D")
			label.text = str(p.count)
			label.visible = true
			pip_meshes.append(m)
		else:
			for ii in p.count:
				var m: MeshInstance3D = pip_template.duplicate()
				var mat: StandardMaterial3D = m.material_override.duplicate()
				m.material_override = mat
				mat.albedo_texture = PIP_TEXTURES[p.type]
				pip_meshes.append(m)
	if pip_meshes.size() > 1:
		for i in pip_meshes.size():
			pip_meshes[i].position += POSITIONS[i]
	for i in pip_meshes.size():
		pip_meshes[i].visible = true
		add_child(pip_meshes[i])
