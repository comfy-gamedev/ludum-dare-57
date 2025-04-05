class_name StuffDieFace
extends Resource

@export var pips: Dictionary[Enums.PIP_TYPE,int]
@export var autolocking: bool

func _init(p_pips: Dictionary[Enums.PIP_TYPE,int] = {}, p_autolocking: bool = false) -> void:
	pips = p_pips
	autolocking = p_autolocking
