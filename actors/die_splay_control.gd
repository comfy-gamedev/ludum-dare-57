@tool
extends Control

var die: Object:
	set(v):
		if die == v: return
		if die:
			die.changed.disconnect(_reconcile)
			for i in 6:
				die.faces[i].changed.disconnect(_reconcile_face.bind(i))
		die = v
		if die:
			die.changed.connect(_reconcile)
			for i in 6:
				die.faces[i].changed.connect(_reconcile_face.bind(i))
		_reconcile()

@onready var die_faces: Array[TextureRect] = [
	$DieFaceControl,
	$DieFaceControl2,
	$DieFaceControl3,
	$DieFaceControl4,
	$DieFaceControl5,
	$DieFaceControl6,
]

func _ready() -> void:
	_reconcile()

func _reconcile():
	if not is_node_ready():
		return
	for i in 6:
		_reconcile_face(i)

func _reconcile_face(i: int) -> void:
	if not is_node_ready():
		return
	var pips: Dictionary[Enums.PIP_TYPE, int] = die.get_total_pips(i) if die else ({} as Dictionary[Enums.PIP_TYPE, int])
	die_faces[i].pips = pips
