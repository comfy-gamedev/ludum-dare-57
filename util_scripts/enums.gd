class_name Enums
extends RefCounted

enum PIP_TYPE {
	ATTACK,
	REND,
	POISON,
	DEFEND,
	ARMOR,
	HEAL,
	REROLL,
	NULLIFY,
	SLIME,
}

const PIP_TEXTURES = {
	Enums.PIP_TYPE.ATTACK: preload("res://assets/textures/pip_attack.png"),
	Enums.PIP_TYPE.DEFEND: preload("res://assets/textures/pip_shield.png"),
	Enums.PIP_TYPE.REROLL: preload("res://assets/textures/pip_reroll.png"),
	Enums.PIP_TYPE.SLIME: preload("res://assets/textures/pip_slime.png"),
	Enums.PIP_TYPE.POISON: preload("res://assets/textures/pip_poison.png"),
	Enums.PIP_TYPE.HEAL: preload("res://assets/textures/pip_heal.png"),
}

enum LOCATION_TYPES {
	ENEMY = 1,
	ELITE = 2,
	TREASURE = 0,
	EVENT = 3,
	EMPTY = 7,
	BOSS = 6,
	MUTATION = 4,
	SHOP = 5,
}

enum LOCATION_STATE {
	CROSSED = 0,
	AVAILABLE = 1,
	HIGHLIGHT = 2,
	DISABLED = 3,
}

enum ENEMY_ACTION {
	PASS,
	ATTACK,
	DEFEND,
	HEAL,
	STRENGTH,
}

enum ENEMY_ACTION_MODE {
	LOOP,
	RANDOM,
}

enum TRIGGERS {
	COMBAT_START,
	TURN_START,
	FIRST_ROLL,
	REROLL,
	GO,
	PRE_TAKE_DAMAGE,
	POST_TAKE_DAMAGE,
	PRE_DEAL_DAMAGE,
	POST_DEAL_DAMAGE,
}

enum ITEMS {
	LEAD_PIPE,
	SLIMY_LEAD_PIPE,
	PIPE_WITH_NAIL,
	BOARD,
	DAGGER,
	POISON_DAGGER,
	MANHOLE_COVER,
	SLEDGEHAMMER,
	GLASS_BOTTLE,
	HAMMER,
	SHIV,
	PIPE_WRENCH,
	PADDLE,
	Vitamins,
	EMPTY_POISON_BOTTLE,
	FULL_BEER_BOTTLE,
	PAIR_OF_SHOES,
	WARM_EGG,
	PACK_OF_CDS,
	BUCKET_OF_SLIME,
	FISHING_ROD,
	BAG_OF_PENNIES,
	REALLY_LONG_SHOELACE,
	GLASSES,
	TEMPORARY_TATTOO,
	TRAFFIC_CONE_HAT,
	ARM_WARMERS
}
