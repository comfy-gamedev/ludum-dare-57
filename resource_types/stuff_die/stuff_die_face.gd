class_name StuffDieFace
extends Resource

@export var pips: Dictionary[Enums.PIP_TYPE,int]
@export var autolocking: bool

func _init(p_pips: Dictionary[Enums.PIP_TYPE,int] = {}, p_autolocking: bool = false) -> void:
	pips = p_pips
	autolocking = p_autolocking

func get_pips(pip_type: Enums.PIP_TYPE):
	return pips[pip_type] if pip_type in pips else 0
	
func set_pips(pip_type: Enums.PIP_TYPE, pip_value: int):
	pips[pip_type] = pip_value
