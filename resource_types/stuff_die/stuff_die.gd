@tool
class_name StuffDie
extends Resource

@export var name: String:
	set(v):
		name = v
		emit_changed()

@export var item_image: Texture2D:
	set(v):
		item_image = v
		emit_changed()

@export var item_rarity: Enums.ITEM_RARITY:
	set(v):
		item_rarity = v
		emit_changed()

@export var faces: Array[StuffDieFace]:
	set(v):
		faces = v
		emit_changed()

@export var count: int = 1:
	set(v):
		count = v
		emit_changed()

@export var roll_effects: Array[RollEffect]:
	set(v):
		roll_effects = v
		emit_changed()


func get_total_pips(face: int) -> Dictionary[Enums.PIP_TYPE, int]:
	return faces[face].pips.duplicate()

func apply_roll_effects(battle_state: BattleState):
	for effect in roll_effects:
		effect.apply(battle_state)
