class_name Mutation
#extends Resource
@export var id  : MUTATIONS
@export var name : String:
	get:
		return names[id]
@export var mutation_image: Texture2D
#@export var trigger : TRIGGERS

enum MUTATIONS {
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

enum TRIGGERS {
	TAKE_DAMAGE,
	DEAL_DAMAGE,
	ROLL_ATTACK,
	ROLL_BLOCK,
	ROLL_DIE,
	ROLL_BLANK,
	ROLL_UNDER,
	ROLL_OVER
}

const names = {
	MUTATIONS.ENLARGED_EYES: "Enlarged Eyes",
	MUTATIONS.SPIKY: "Spikey",
	MUTATIONS.LEATHERY_SKIN: "Leathery Skin",
	MUTATIONS.HARDENED_SCALES: "Hardened Scales",
	MUTATIONS.HEIGHTENED_INSTINCTS: "Hightened Instincts",
	MUTATIONS.BUSTY: "Busty",
	MUTATIONS.SLIMEY: "Slimey",
	MUTATIONS.SHELLIFIED: "Shellified",
	MUTATIONS.FUZZY: "Fuzzy",
	MUTATIONS.EXTRA_TOES: "Extra Toes",
	MUTATIONS.HOLLOW_TEETH: "Hollow Teeth",
}

func triggered(trigger_event: TRIGGERS, battle_state: BattleState):
	#if trigger_event != trigger:
		#return
	
	match id:
		MUTATIONS.ENLARGED_EYES:
			pass
		MUTATIONS.SPIKY:
			pass
		MUTATIONS.LEATHERY_SKIN:
			pass
		MUTATIONS.HARDENED_SCALES:
			pass
		MUTATIONS.HEIGHTENED_INSTINCTS:
			pass
		MUTATIONS.BUSTY:
			pass
		MUTATIONS.SLIMEY:
			pass
		MUTATIONS.SHELLIFIED:
			pass
		MUTATIONS.FUZZY:
			pass
		MUTATIONS.EXTRA_TOES:
			pass
		MUTATIONS.HOLLOW_TEETH:
			pass
