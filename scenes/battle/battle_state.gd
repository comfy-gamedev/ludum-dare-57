class_name BattleState
extends RefCounted

signal enemy_intent_changed()

var deck: Array[LayeredDie]
var hand: Array[LayeredDie]
var discard: Array[LayeredDie]
var roll_results: Array[LayeredDie]

var enemy_state: CharacterState = CharacterState.new()
var player_state: CharacterState = CharacterState.new()

var enemy: Enemy
var enemy_act: Dictionary

var _enemy_action_index: int = -1

func prepare_enemy_act() -> void:
	if enemy_state.get_status_pip(Enums.PIP_TYPE.SLIME) > 0:
		enemy_act = {
			action = Enums.ENEMY_ACTION.PASS,
			param = 0,
		}
		enemy_state.set_status_pip(Enums.PIP_TYPE.SLIME, 0)
		enemy_intent_changed.emit()
		return
	
	match enemy.action_mode:
		Enums.ENEMY_ACTION_MODE.LOOP:
			_enemy_action_index += 1
			if _enemy_action_index >= enemy.actions.size():
				_enemy_action_index = enemy.action_loop_point
		Enums.ENEMY_ACTION_MODE.RANDOM:
			# https://en.wikipedia.org/wiki/Reservoir_sampling#Algorithm_A-ExpJ
			# https://doi.org/10.1016/j.ipl.2005.11.003
			var result = 0
			var roll = randf() ** (1.0 / enemy.actions[0].random_weight)
			var jump = log(randf()) / log(roll)
			for i in range(1, enemy.actions.size()):
				jump -= enemy.actions[i].random_weight
				if jump <= 0.0:
					var t = roll ** enemy.actions[i].random_weight
					roll = randf_range(t, 1.0) ** (1.0 / enemy.actions[i].random_weight)
					result = i
					jump = log(randf()) / log(roll)
			_enemy_action_index = result
	
	_enemy_action_index = clampi(_enemy_action_index, 0, enemy.actions.size())
	
	enemy_act = {
		action = enemy.actions[_enemy_action_index].action,
		param = enemy.actions[_enemy_action_index].action_param,
	}
	
	enemy_intent_changed.emit()

class CharacterState:
	signal changed()
	signal pre_damage(data: Dictionary)
	signal post_damage(data: Dictionary)
	
	var hp: int:
		set(v):
			if hp == v: return
			hp = v
			changed.emit()
	
	var mana: int = -1:
		set(v):
			if mana == v: return
			mana = v
			changed.emit()
	
	var rerolls: int = -1:
		set(v):
			if rerolls == v: return
			rerolls = v
			changed.emit()
	
	var status_pips: Dictionary[Enums.PIP_TYPE, int]:
		set(v):
			if status_pips == v: return
			status_pips = v
			changed.emit()
	
	func get_status_pip(pip_type: Enums.PIP_TYPE) -> int:
		return status_pips.get(pip_type, 0)
	
	func set_status_pip(pip_type: Enums.PIP_TYPE, amount: int) -> void:
		if amount == status_pips.get(pip_type, 0): return
		if amount:
			status_pips[pip_type] = amount
		else:
			status_pips.erase(pip_type)
		changed.emit()
	
	func add_status_pip(pip_type: Enums.PIP_TYPE, amount: int) -> void:
		set_status_pip(pip_type, get_status_pip(pip_type) + amount)
	
	func deal_damage(amount: int) -> int:
		var shield = get_status_pip(Enums.PIP_TYPE.DEFEND)
		var blocked: int = 0
		if shield:
			blocked = mini(shield, amount)
			amount -= blocked
			add_status_pip(Enums.PIP_TYPE.DEFEND, -blocked)
		amount = mini(amount, hp)
		
		var data = { damage = amount, blocked = blocked }
		pre_damage.emit(data)
		if data.damage > 0:
			hp -= data.damage
		post_damage.emit(data)
		changed.emit()
		return data.damage
	

