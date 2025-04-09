class_name LayeredDie
extends RefCounted

signal changed()

var source_die: StuffDie
var battle_sprite: DieSprite
var rolled_face: int = -1

var faces: Array[LayeredDieFace]

var _persistent_buff_pips: Dictionary[Enums.PIP_TYPE, int]
var _turn_buff_pips: Dictionary[Enums.PIP_TYPE, int]
var _roll_buff_pips: Dictionary[Enums.PIP_TYPE, int]

func _init(p_die: StuffDie) -> void:
	source_die = p_die
	for i in 6:
		faces.append(LayeredDieFace.new())

func get_total_pips(face: int = -1) -> Dictionary[Enums.PIP_TYPE, int]:
	if face == -1:
		face = rolled_face
	assert(face != -1, "Must have a valid face index or rolled_face.")
	
	var result: Dictionary[Enums.PIP_TYPE, int] = source_die.faces[face].pips.duplicate()
	
	for type in faces[face]._persistent_pips:
		result[type] = result.get(type, 0) + faces[face]._persistent_pips[type]
	
	for type in faces[face]._turn_pips:
		result[type] = result.get(type, 0) + faces[face]._turn_pips[type]
	
	for type in faces[face]._roll_pips:
		result[type] = result.get(type, 0) + faces[face]._roll_pips[type]
	
	for type in result:
		result[type] += _persistent_buff_pips.get(type, 0)
		result[type] += _turn_buff_pips.get(type, 0)
		result[type] += _roll_buff_pips.get(type, 0)
	
	for type in result.keys():
		if result[type] <= 0:
			result.erase(type)
	
	return result

func add_persistent_pip(face: int, type: Enums.PIP_TYPE, count: int) -> void:
	faces[face]._persistent_pips[type] = faces[face]._persistent_pips.get(type, 0) + count
	changed.emit()

func add_persistent_buff(type: Enums.PIP_TYPE, count: int) -> void:
	_persistent_buff_pips[type] = _persistent_buff_pips.get(type, 0) + count
	changed.emit()

func add_turn_pip(face: int, type: Enums.PIP_TYPE, count: int) -> void:
	faces[face]._turn_pips[type] = faces[face]._turn_pips.get(type, 0) + count
	changed.emit()

func add_turn_buff(type: Enums.PIP_TYPE, count: int) -> void:
	_turn_buff_pips[type] = _turn_buff_pips.get(type, 0) + count
	changed.emit()

func add_roll_pip(face: int, type: Enums.PIP_TYPE, count: int) -> void:
	faces[face]._roll_pips[type] = faces[face]._roll_pips.get(type, 0) + count
	changed.emit()

func add_roll_buff(type: Enums.PIP_TYPE, count: int) -> void:
	_roll_buff_pips[type] = _roll_buff_pips.get(type, 0) + count
	changed.emit()

func clear_turn_pips() -> void:
	_turn_buff_pips.clear()
	for f in faces:
		f._turn_pips.clear()
	changed.emit()

func clear_roll_pips() -> void:
	_roll_buff_pips.clear()
	for f in faces:
		f._roll_pips.clear()
	changed.emit()

class LayeredDieFace:
	var _persistent_pips: Dictionary[Enums.PIP_TYPE, int]
	var _turn_pips: Dictionary[Enums.PIP_TYPE, int]
	var _roll_pips: Dictionary[Enums.PIP_TYPE, int]
