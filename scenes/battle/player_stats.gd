class_name PlayerStats
extends RefCounted

signal changed()

var max_health: int = 10:
	set(v):
		if max_health == v: return
		max_health = v
		changed.emit()

var health: int = 10:
	set(v):
		if health == v: return
		health = v
		changed.emit()

var initial_mana: int = 3:
	set(v):
		if initial_mana == v: return
		initial_mana = v
		changed.emit()

var initial_rerolls: int = 1:
	set(v):
		if initial_rerolls == v: return
		initial_rerolls = v
		changed.emit()

var equipment: Array[StuffDie]:
	set(v):
		if equipment == v: return
		equipment = v
		changed.emit()

var mutations: Array[Mutation]:
	set(v):
		if mutations == v: return
		mutations = v
		changed.emit()
