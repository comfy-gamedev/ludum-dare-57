class_name DieModel
extends Node3D

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

func _ready() -> void:
	_reconcile()

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
			die_faces[i].face = underlying.faces[i]
			die_faces[i].pips = die.get_total_pips(i)
			die_faces[i].visible = true
	
