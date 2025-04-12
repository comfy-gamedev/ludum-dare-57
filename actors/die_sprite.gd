class_name DieSprite
extends Sprite2D

signal clicked()
signal mouse_enter()
signal mouse_exit()

const MOUSE_SENSITIVITY = Vector2.ONE / 30.0
const FLOAT_DAMPING = 0.95

enum AnimMode {
	NONE,
	FLOATING,
	ROLLING,
}

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

var die: LayeredDie:
	set(v):
		if die == v: return
		if die:
			die.battle_sprite = null
		die = v
		if die:
			die.battle_sprite = self
		_reconcile()

var _time: float = 0.0
var _added_rotation: Quaternion
var _outline_override: Color = Color.TRANSPARENT:
	set(v):
		if _outline_override == v: return
		_outline_override = v
		_reconcile()
var _float_velocity: Vector2
var _roll_offset_axis_angle: Vector3

@onready var die_node: DieModel = $SubViewport/Die as DieModel
@onready var sub_viewport: SubViewport = $SubViewport

func _ready() -> void:
	_reconcile()

func _process(delta: float) -> void:
	match animation_mode:
		AnimMode.NONE:
			_added_rotation = Quaternion.IDENTITY
			_reconcile()
			set_process(false)
			return
		AnimMode.FLOATING:
			if _float_velocity.length() > 1.0:
				_time += delta
			var vel = _float_velocity.rotated(sin(_time) * TAU / 4.0)
			_added_rotation = Quaternion.from_euler(Vector3(vel.y, vel.x, 0.0)) * _added_rotation
			_float_velocity *= FLOAT_DAMPING
			_reconcile()
			return
		AnimMode.ROLLING:
			_added_rotation = Quaternion(_roll_offset_axis_angle.normalized(), _roll_offset_axis_angle.length())
			_reconcile()
			return

func get_combined_rotation() -> Quaternion:
	var rot = _added_rotation * die_rotation
	match animation_mode:
		AnimMode.FLOATING:
			rot = Quaternion.from_euler(Vector3(0, 0, sin(_time) * TAU / 4.0)) * rot
	return rot

func random_tap() -> void:
	_float_velocity = Vector2.from_angle(TAU * randf()) * 0.5

func roll() -> void:
	animation_mode = AnimMode.ROLLING
	die_rotation = die_node.get_face_orientation(die.rolled_face)
	var axis = Vector2.from_angle(TAU * randf())
	var angle = randf_range(TAU, TAU * 2.0)
	_roll_offset_axis_angle = Vector3(axis.x, axis.y, 0.0) * angle
	var t = create_tween()
	t.tween_property(self, "_roll_offset_axis_angle", Vector3.ZERO, 0.2)
	await t.finished
	animation_mode = AnimMode.NONE

func is_rolling() -> bool:
	return animation_mode == AnimMode.ROLLING

func _reconcile() -> void:
	if not is_node_ready(): return
	die_node.die = die
	die_node.basis = Basis(get_combined_rotation()).scaled(Vector3.ONE * die_scale)
	(material as ShaderMaterial).set_shader_parameter("outline_color", _outline_override if _outline_override.a != 0 else outline_color)
	sub_viewport.render_target_update_mode = SubViewport.UPDATE_ONCE

func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event.is_action_pressed("click"):
		clicked.emit()
	elif event is InputEventMouseMotion:
		_float_velocity = event.relative * MOUSE_SENSITIVITY


func _on_area_2d_mouse_entered() -> void:
	_outline_override = Color.YELLOW
	mouse_enter.emit()


func _on_area_2d_mouse_exited() -> void:
	_outline_override = Color.TRANSPARENT
	mouse_exit.emit()
