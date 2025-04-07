extends Node3D

@export var die: StuffDie:
	set(v):
		if die == v: return
		die = v
		_reconcile()

@onready var die_faces: Array[Node3D] = [
	$DieFace0,
	$DieFace1,
	$DieFace2,
	$DieFace3,
	$DieFace4,
	$DieFace5,
]

func _ready() -> void:
	_reconcile()

func get_face_orientation(index: int) -> Basis:
	return die_faces[index].basis.inverse()

func _reconcile():
	if not is_inside_tree():
		return
	for i in 6:
		if die == null or i >= die.faces.size():
			die_faces[i].visible = false
		else:
			die_faces[i].face = die.faces[i]
			die_faces[i].visible = true
	
