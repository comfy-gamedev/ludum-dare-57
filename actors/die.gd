class_name DieModel
extends Node3D

@export var outline: bool = false:
	set(v):
		outline = v
		_update_outline()

@export var outline_color: Color = Color("e09ea0"):
	set(v):
		outline_color = v
		_update_outline()

var die: Object:
	set(v):
		if die == v: return
		if die is LayeredDie:
			die.changed.disconnect(_reconcile)
		die = v
		if die is LayeredDie:
			die.changed.connect(_reconcile)
		_reconcile()

@onready var die_faces: Array[Node3D] = [
	$DieFace0,
	$DieFace1,
	$DieFace2,
	$DieFace3,
	$DieFace4,
	$DieFace5,
]
@onready var outline_mesh: MeshInstance3D = $Outline

func _ready() -> void:
	_reconcile()
	_update_outline()

func get_face_orientation(index: int) -> Basis:
	return die_faces[index].basis.inverse()

func _reconcile():
	if not is_inside_tree():
		return
	for i in 6:
		if die == null:
			die_faces[i].visible = false
			continue
		var underlying = die.source_die if die is LayeredDie else die
		if i >= underlying.faces.size():
			die_faces[i].visible = false
		else:
			die_faces[i].pips = die.get_total_pips(i)
			die_faces[i].visible = true

func _update_outline() -> void:
	outline_mesh.visible = outline
	if outline:
		outline_mesh.mesh.material.albedo_color = outline_color
