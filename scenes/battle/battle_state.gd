class_name BattleState
extends RefCounted

signal changed()

var deck: Array[LayeredDie]:
	set(v):
		if deck == v: return
		deck = v
		changed.emit()

var hand: Array[LayeredDie]:
	set(v):
		if hand == v: return
		hand = v
		changed.emit()

var discard: Array[LayeredDie]:
	set(v):
		if discard == v: return
		discard = v
		changed.emit()

var roll_results: Array[RollResult]:
	set(v):
		if roll_results == v: return
		roll_results = v
		changed.emit()


var mana: int:
	set(v):
		if mana == v: return
		mana = v
		changed.emit()

var rerolls: int:
	set(v):
		if rerolls == v: return
		rerolls = v
		changed.emit()


var enemy: Enemy:
	set(v):
		if enemy == v: return
		enemy = v
		changed.emit()

var enemy_hp: int:
	set(v):
		if enemy_hp == v: return
		enemy_hp = v
		changed.emit()

var enemy_action_index: int:
	set(v):
		if enemy_action_index == v: return
		enemy_action_index = v
		changed.emit()


var player_shield: int:
	set(v):
		if player_shield == v: return
		player_shield = v
		changed.emit()


class RollResult:
	var die: LayeredDie
	var face: int
	
	func _init(p_die: LayeredDie, p_face: int) -> void:
		die = p_die
		face = p_face


class LayeredDie:
	var source_die: StuffDie
	var faces: Array[LayeredDieFace]
	
	var persistent_buff_pips: Dictionary[Enums.PIP_TYPE, int]
	var temporary_buff_pips: Dictionary[Enums.PIP_TYPE, int]
	
	var battle_sprite: DieSprite
	
	func _init(p_die: StuffDie) -> void:
		source_die = p_die
		for i in 6:
			faces.append(LayeredDieFace.new())
	
	func get_total_pips(face: int) -> Dictionary[Enums.PIP_TYPE, int]:
		var result: Dictionary[Enums.PIP_TYPE, int] = {}
		for type in source_die.faces[face].pips:
			result[type] = result.get(type, 0) + source_die.faces[face].pips[type]
		for type in faces[face].persistent_pips:
			result[type] = result.get(type, 0) + faces[face].persistent_pips
		for type in faces[face].temporary_pips:
			result[type] = result.get(type, 0) + faces[face].temporary_pips
		for type in result:
			result[type] += persistent_buff_pips.get(type, 0)
			result[type] += temporary_buff_pips.get(type, 0)
		return result
	
	func add_persistent_pip(face: int, type: Enums.PIP_TYPE, count: int) -> void:
		faces[face].persistent_pips[type] = faces[face].persistent_pips.get(type, 0) + count
	
	func add_persistent_buff(type: Enums.PIP_TYPE, count: int) -> void:
		persistent_buff_pips[type] = persistent_buff_pips.get(type, 0) + count
	
	func add_temporary_pip(face: int, type: Enums.PIP_TYPE, count: int) -> void:
		faces[face].temporary_pips[type] = faces[face].temporary_pips.get(type, 0) + count
	
	func add_temporary_buff(type: Enums.PIP_TYPE, count: int) -> void:
		temporary_buff_pips[type] = temporary_buff_pips.get(type, 0) + count
	
	func clear_temporary_pips() -> void:
		temporary_buff_pips.clear()
		for f in faces:
			f.temporary_pips.clear()

class LayeredDieFace:
	var persistent_pips: Dictionary[Enums.PIP_TYPE, int]
	var temporary_pips: Dictionary[Enums.PIP_TYPE, int]
