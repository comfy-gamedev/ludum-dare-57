class_name Mutation
extends Resource

@export var name: String
@export var mutation_image: Texture2D
@export var mutation_effects: Array[Enums.EFFECTS]
@export var mutation_triggers: Array[Enums.TRIGGERS]
@export var effect_values: Array[int]

func _init(
	p_name: String = "",
	p_mutation_image: Texture2D = null,
	p_mutation_effects: Array[Enums.EFFECTS] = [],
	p_mutation_triggers: Array[Enums.TRIGGERS] = [],
	p_effect_values: Array[int] = []
):
	name = p_name
	mutation_image = p_mutation_image
	mutation_effects = p_mutation_effects
	mutation_triggers = p_mutation_triggers
	effect_values = p_effect_values
