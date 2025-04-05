class_name ModifyPips
extends RollEffect

@export var mod_type: Enums.PIP_TYPE = Enums.PIP_TYPE.ATTACK
@export var mod_value: int = 1

func apply(battle_state):
	battle_state.roll_result[mod_type] += mod_value
