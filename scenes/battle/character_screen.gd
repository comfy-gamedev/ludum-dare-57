@tool
class_name CharacterScreen
extends Panel

enum Align {
	LEFT,
	RIGHT,
}

const MAX_PIPS = 12
const DIE_FACE_PIP = preload("res://actors/die_face_pip.tscn")

@export var align: Align = Align.LEFT: set = set_align

var character_state: BattleState.CharacterState:
	set(v):
		if character_state == v: return
		if character_state:
			character_state.changed.disconnect(_on_character_state_changed)
		character_state = v
		if character_state:
			character_state.changed.connect(_on_character_state_changed)
		_on_character_state_changed()

@onready var sprite: Sprite2D = %Sprite
@onready var display_alignment: HBoxContainer = %DisplayAlignment
@onready var health_panel: TextureRect = %HealthPanel
@onready var health_label: Label = %HealthLabel
@onready var rerolls_panel: TextureRect = %RerollsPanel
@onready var rerolls_label: Label = %RerollsLabel
@onready var mana_panel: TextureRect = %ManaPanel
@onready var mana_label: Label = %ManaLabel
@onready var status_pips: HBoxContainer = %StatusPips

@onready var _sprite_initial_position: Vector2 = sprite.position

func _ready() -> void:
	_update_align()

func set_align(v: Align) -> void:
	if align == v: return
	align = v
	_update_align()

func shake() -> void:
	var t = create_tween()
	t.tween_method(func (x: float):
		sprite.position.x = _sprite_initial_position.x + (-10 if floori(x) % 2 == 0 else 10)
	, 0.0, 10.0, 0.5)
	t.tween_callback(func ():
		sprite.position = _sprite_initial_position)

func _update_align() -> void:
	if not is_inside_tree(): return
	match align:
		Align.LEFT:
			display_alignment.alignment = BoxContainer.ALIGNMENT_BEGIN
			status_pips.alignment = BoxContainer.ALIGNMENT_BEGIN
			status_pips.grow_horizontal = Control.GROW_DIRECTION_END
		Align.RIGHT:
			display_alignment.alignment = BoxContainer.ALIGNMENT_END
			status_pips.alignment = BoxContainer.ALIGNMENT_END
			status_pips.grow_horizontal = Control.GROW_DIRECTION_BEGIN

func _on_character_state_changed() -> void:
	health_label.text = str(character_state.hp)
	mana_label.text = str(character_state.mana)
	rerolls_label.text = str(character_state.rerolls)
	_set_status_pips(character_state.status_pips)


func _set_status_pips(pips: Dictionary[Enums.PIP_TYPE, int]) -> void:
	var pip_list = PipUtils.deconstruct_pips(pips, MAX_PIPS)
	
	for i in pip_list.size():
		var p = pip_list[i]
		var pip: TextureRect
		if i < status_pips.get_child_count():
			pip = status_pips.get_child(i)
		else:
			pip = DIE_FACE_PIP.instantiate()
			status_pips.add_child(pip)
		pip.show()
		pip.texture = Enums.PIP_TEXTURES[p.type]
		if p.count > 1:
			pip.label.text = str(p.count)
			pip.label.show()
		else:
			pip.label.hide()
			pip.label.text = ""
	
	for i in range(pip_list.size(), status_pips.get_child_count()):
		status_pips.get_child(i).hide()
