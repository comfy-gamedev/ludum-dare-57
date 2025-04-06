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
}

enum ENEMY_ACTION_MODE {
	LOOP,
	RANDOM,
}

#enum EFFECTS {
	#ADD_PIP,
	#REMOVE_PIP,
	#DOUBLE_FACE,
	#TAKE_DAMAGE, # ⌄ Only when cannot be done with pips
	#DEAL_DAMAGE,
	#HEAL,
#}
