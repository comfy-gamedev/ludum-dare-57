@tool
class_name PipUtils
extends RefCounted

static func deconstruct_pips(pip_dict: Dictionary[Enums.PIP_TYPE, int], max_pips: int) -> Array[Dictionary]:
	var pip_list: Array[Dictionary]
	
	for p in pip_dict:
		if pip_dict[p] > 0:
			pip_list.push_back({ type = p, count = pip_dict[p] })
	
	pip_list.sort_custom(func (a, b): return a.count < b.count)
	while pip_list.size() < max_pips:
		var i = pip_list.find_custom(func (x): return x.count > 1)
		if i == -1:
			break
		if pip_list[i].count > max_pips - pip_list.size():
			break
		var p = pip_list[i]
		pip_list.remove_at(i)
		var p1 = { type = p.type, count = 1 }
		for j in p.count:
			pip_list.insert(i, p1)
	
	return pip_list



static func pip_trigger_event(pip_type: Enums.PIP_TYPE, trigger: Enums.TRIGGER, data: Dictionary = {}) -> void:
	pass

