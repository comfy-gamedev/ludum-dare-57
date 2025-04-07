class_name Mutation
extends RefCounted

@export var kind: KIND
@export var name: String:
	get:
		return names[kind]
@export var mutation_image: Texture2D

enum KIND {
	ENLARGED_EYES,
	SPIKY,
	LEATHERY_SKIN,
	HARDENED_SCALES,
	HEIGHTENED_INSTINCTS,
	BUSTY,
	SLIMEY,
	SHELLIFIED,
	FUZZY,
	EXTRA_TOES,
	HOLLOW_TEETH
}

const names = {
	KIND.ENLARGED_EYES: "Enlarged Eyes",
	KIND.SPIKY: "Spikey",
	KIND.LEATHERY_SKIN: "Leathery Skin",
	KIND.HARDENED_SCALES: "Hardened Scales",
	KIND.HEIGHTENED_INSTINCTS: "Hightened Instincts",
	KIND.BUSTY: "Busty",
	KIND.SLIMEY: "Slimey",
	KIND.SHELLIFIED: "Shellified",
	KIND.FUZZY: "Fuzzy",
	KIND.EXTRA_TOES: "Extra Toes",
	KIND.HOLLOW_TEETH: "Hollow Teeth",
}

func triggered(trigger_event: Enums.TRIGGERS, data: Dictionary, battle_state: BattleState):
	print("triggered ", self)
	match kind:
		KIND.ENLARGED_EYES:
			match trigger_event:
				Enums.TRIGGERS.COMBAT_START:
					print("Applying mutation ENLARGED_EYES")
					for d in battle_state.deck:
						d.add_persistent_buff(Enums.PIP_TYPE.DEFEND, 1)
		KIND.SPIKY:
			pass
		KIND.LEATHERY_SKIN:
			pass
		KIND.HARDENED_SCALES:
			pass
		KIND.HEIGHTENED_INSTINCTS:
			pass
		KIND.BUSTY:
			pass
		KIND.SLIMEY:
			pass
		KIND.SHELLIFIED:
			pass
		KIND.FUZZY:
			pass
		KIND.EXTRA_TOES:
			pass
		KIND.HOLLOW_TEETH:
			pass
