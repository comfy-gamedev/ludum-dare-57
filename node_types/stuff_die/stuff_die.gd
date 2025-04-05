class_name StuffDie
extends Resource

@export var name: String
@export var item_image: Texture2D
@export var faces: Array[StuffDieFace]
@export var roll_effects: Array[RollEffect]

func _init(
	p_name: String = "",
	p_item_image: Texture2D = null,
	p_faces: Array[StuffDieFace] = [],
	p_roll_effects: Array[RollEffect] = [],
):
	name = p_name
	item_image = p_item_image
	faces = p_faces
	roll_effects = p_roll_effects

func apply_roll_effects(battle_state):
	for effect in roll_effects:
		effect.apply(battle_state)
