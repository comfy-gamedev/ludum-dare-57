class_name DieSprite
extends Sprite2D

const SNAPPAGE = TAU / 12.0

enum AnimMode {
	NONE,
	FLOATING,
}

@export var die: StuffDie:
	set(v):
		if die == v: return
		die = v
		_reconcile()

@export var die_rotation: Quaternion = Quaternion.IDENTITY:
	set(v):
		if die_rotation == v: return
		die_rotation = v
		_reconcile()

@export var die_scale: float = 1.0:
	set(v):
		if die_scale == v: return
		die_scale = v
		_reconcile()

@export var animation_mode: AnimMode = AnimMode.NONE:
	set(v):
		if animation_mode == v: return
		animation_mode = v
		set_process(true)

var _time: float = 0.0
var _added_rotation: Quaternion

@onready var die_node: Node3D = $SubViewport/Die

func _ready() -> void:
	_reconcile()

func _process(delta: float) -> void:
	_time += delta
	match animation_mode:
		AnimMode.NONE:
			set_process(false)
			return
		AnimMode.FLOATING:
			var rot = die_rotation.get_euler() + TAU * Vector3(sin(_time), cos(_time), sin(_time * 0.3))
			_added_rotation = Quaternion.from_euler(rot.snappedf(SNAPPAGE))
			_reconcile()
			return

func _reconcile() -> void:
	if die_node:
		die_node.die = die
		die_node.basis = Basis.from_euler((_added_rotation * die_rotation).get_euler().snappedf(SNAPPAGE)).scaled(Vector3.ONE * die_scale)

