class_name Enums
extends RefCounted

enum PIP_TYPE {
	ATTACK = 0,
	POISON = 2,
	DEFEND = 3,
	HEAL = 5,
	REROLL = 6,
	SLIME = 8,
	DRAW = 9,
	MANA = 10,
	INSTANT_ATTACK = 11,
	INSTANT_PAIN = 12,
	STRENGTH = 13,
}

const PIP_TEXTURES = {
	Enums.PIP_TYPE.ATTACK: preload("res://assets/textures/pip_attack.png"),
	Enums.PIP_TYPE.DEFEND: preload("res://assets/textures/pip_shield.png"),
	Enums.PIP_TYPE.REROLL: preload("res://assets/textures/pip_reroll.png"),
	Enums.PIP_TYPE.SLIME: preload("res://assets/textures/pip_slime.png"),
	Enums.PIP_TYPE.POISON: preload("res://assets/textures/pip_poison.png"),
	Enums.PIP_TYPE.HEAL: preload("res://assets/textures/pip_heal.png"),
	Enums.PIP_TYPE.DRAW: preload("res://assets/textures/pip_draw.png"),
	Enums.PIP_TYPE.MANA: preload("res://assets/textures/pip_mana.png"),
	Enums.PIP_TYPE.INSTANT_ATTACK: preload("res://assets/textures/pip_immediate_damage.png"),
	Enums.PIP_TYPE.INSTANT_PAIN: preload("res://assets/textures/pip_immediate_wound.png"),
	Enums.PIP_TYPE.STRENGTH: preload("res://assets/textures/pip_strength.png"),
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

enum TRIGGER {
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

enum UPGRADE_REASON {
	TREASURE,
	MUTATION,
	ENEMY,
	ELITE,
	BOSS,
}

enum ITEM_RARITY {
	COMMON,
	UNCOMMON,
	RARE,
	ULTRA_RARE,
	UNAVAILABLE,
}
