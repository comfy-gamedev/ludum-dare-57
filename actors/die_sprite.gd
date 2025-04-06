class_name DieSprite
extends Sprite2D

signal clicked()

const SNAPPAGE = TAU / 12.0

enum AnimMode {
	NONE,
	FLOATING,
}

@export var die: StuffDie:
	set(v):
		if die == v: return
		if die:
			die._battle_sprite = null
		die = v
		if die:
			die._battle_sprite = self
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

@export var outline_color: Color = Color.TRANSPARENT:
	set(v):
		if outline_color == v: return
		outline_color = v
		_reconcile()

var _time: float = 0.0
var _added_rotation: Quaternion
var _outline_override: Color = Color.TRANSPARENT:
	set(v):
		if _outline_override == v: return
		_outline_override = v
		_reconcile()

@onready var die_node: Node3D = $SubViewport/Die

func _ready() -> void:
	_reconcile()

func _process(delta: float) -> void:
	_time += delta
	match animation_mode:
		AnimMode.NONE:
			_added_rotation = Quaternion.IDENTITY
			set_process(false)
			return
		AnimMode.FLOATING:
			var rot = die_rotation.get_euler() + TAU * Vector3(sin(_time), cos(_time), sin(_time * 0.3))
			_added_rotation = Quaternion.from_euler(rot.snappedf(SNAPPAGE))
			_reconcile()
			return

func get_combined_rotation() -> Quaternion:
	return _added_rotation * die_rotation

func _reconcile() -> void:
	if die_node:
		die_node.die = die
		die_node.basis = Basis.from_euler(get_combined_rotation().get_euler().snappedf(SNAPPAGE)).scaled(Vector3.ONE * die_scale)
	(material as ShaderMaterial).set_shader_parameter("outline_color", _outline_override if _outline_override.a != 0 else outline_color)

func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event.is_action_pressed("click"):
		clicked.emit()


func _on_area_2d_mouse_entered() -> void:
	_outline_override = Color.YELLOW


func _on_area_2d_mouse_exited() -> void:
	_outline_override = Color.TRANSPARENT
