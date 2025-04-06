class_name BattleState
extends RefCounted

signal changed()

var deck: Array[StuffDie]:
	set(v):
		if deck == v: return
		deck = v
		changed.emit()

var hand: Array[StuffDie]:
	set(v):
		if hand == v: return
		hand = v
		changed.emit()

var discard: Array[StuffDie]:
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
	var die: StuffDie
	var face: int
	
	func _init(p_die: StuffDie, p_face: int) -> void:
		die = p_die
		face = p_face
