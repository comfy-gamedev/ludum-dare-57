extends Control

var die: Object:
	set(v):
		if die == v: return
		if die is LayeredDie:
			die.changed.disconnect(_reconcile)
		die = v
		if die is LayeredDie:
			die.changed.connect(_reconcile)
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
	if not is_inside_tree() or die == null:
		return
	var underlying: StuffDie = die.source_die if die is LayeredDie else die
	for i in 6:
		die_faces[i].face = underlying.faces[i]
		die_faces[i].pips = die.get_total_pips(i)
