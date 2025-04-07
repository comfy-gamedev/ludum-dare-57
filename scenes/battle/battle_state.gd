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

var enemy_poison: int:
	set(v):
		if enemy_poison == v: return
		enemy_poison = v
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
	signal changed()
	
	var source_die: StuffDie
	var faces: Array[LayeredDieFace]
	
	var persistent_buff_pips: Dictionary[Enums.PIP_TYPE, int]
	var turn_buff_pips: Dictionary[Enums.PIP_TYPE, int]
	var roll_buff_pips: Dictionary[Enums.PIP_TYPE, int]
	
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
			result[type] = result.get(type, 0) + faces[face].persistent_pips[type]
		for type in faces[face].turn_pips:
			result[type] = result.get(type, 0) + faces[face].turn_pips[type]
		for type in faces[face].roll_pips:
			result[type] = result.get(type, 0) + faces[face].roll_pips[type]
		for type in result:
			result[type] += persistent_buff_pips.get(type, 0)
			result[type] += turn_buff_pips.get(type, 0)
			result[type] += roll_buff_pips.get(type, 0)
		for type in result.keys():
			if result[type] <= 0:
				result.erase(type)
		return result
	
	func add_persistent_pip(face: int, type: Enums.PIP_TYPE, count: int) -> void:
		faces[face].persistent_pips[type] = faces[face].persistent_pips.get(type, 0) + count
		changed.emit()
	
	func add_persistent_buff(type: Enums.PIP_TYPE, count: int) -> void:
		persistent_buff_pips[type] = persistent_buff_pips.get(type, 0) + count
		changed.emit()
	
	func add_turn_pip(face: int, type: Enums.PIP_TYPE, count: int) -> void:
		faces[face].turn_pips[type] = faces[face].turn_pips.get(type, 0) + count
		changed.emit()
	
	func add_turn_buff(type: Enums.PIP_TYPE, count: int) -> void:
		turn_buff_pips[type] = turn_buff_pips.get(type, 0) + count
		changed.emit()
	
	func add_roll_pip(face: int, type: Enums.PIP_TYPE, count: int) -> void:
		faces[face].roll_pips[type] = faces[face].roll_pips.get(type, 0) + count
		changed.emit()
	
	func add_roll_buff(type: Enums.PIP_TYPE, count: int) -> void:
		roll_buff_pips[type] = roll_buff_pips.get(type, 0) + count
		changed.emit()
	
	func clear_turn_pips() -> void:
		turn_buff_pips.clear()
		for f in faces:
			f.turn_pips.clear()
		changed.emit()
	
	func clear_roll_pips() -> void:
		roll_buff_pips.clear()
		for f in faces:
			f.roll_pips.clear()
		changed.emit()

class LayeredDieFace:
	var persistent_pips: Dictionary[Enums.PIP_TYPE, int]
	var turn_pips: Dictionary[Enums.PIP_TYPE, int]
	var roll_pips: Dictionary[Enums.PIP_TYPE, int]
