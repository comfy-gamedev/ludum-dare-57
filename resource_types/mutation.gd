class_name Mutation
extends RefCounted

var kind: KIND
var name: String:
	get:
		return names[kind]

enum KIND {
	ENLARGED_EYES,
	SPIKY,
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
	KIND.HARDENED_SCALES: "Hardened Scales",
	KIND.HEIGHTENED_INSTINCTS: "Hightened Instincts",
	KIND.BUSTY: "Busty",
	KIND.SLIMEY: "Slimey",
	KIND.SHELLIFIED: "Shellified",
	KIND.FUZZY: "Fuzzy",
	KIND.EXTRA_TOES: "Extra Toes",
	KIND.HOLLOW_TEETH: "Hollow Teeth",
}

const rarity = {
	KIND.ENLARGED_EYES: 1,
	KIND.SPIKY: 1,
	KIND.HARDENED_SCALES: 1,
	KIND.HEIGHTENED_INSTINCTS: 1,
	KIND.BUSTY: 1,
	KIND.SLIMEY: 1,
	KIND.SHELLIFIED: 1,
	KIND.FUZZY: 1,
	KIND.EXTRA_TOES: 1,
	KIND.HOLLOW_TEETH: 1,
}

const textures = {
	KIND.ENLARGED_EYES: null,
	KIND.SPIKY: null,
	KIND.HARDENED_SCALES: null,
	KIND.HEIGHTENED_INSTINCTS: null,
	KIND.BUSTY: null,
	KIND.SLIMEY: null,
	KIND.SHELLIFIED: null,
	KIND.FUZZY: null,
	KIND.EXTRA_TOES: null,
	KIND.HOLLOW_TEETH: null,
}

const descriptions = {
	KIND.ENLARGED_EYES: "Enhances shield faces.",
	KIND.SPIKY: "Weakens attacks, but shields reflect damage.",
	KIND.HARDENED_SCALES: "Replaces blank faces with a shield.",
	KIND.HEIGHTENED_INSTINCTS: "Doubles the damage of the highest attack face.",
	KIND.BUSTY: "Adds slime to blank faces.",
	KIND.SLIMEY: "Adds slime to all attacks.",
	KIND.SHELLIFIED: "Doubles the shields of the highest shield face.",
	KIND.FUZZY: "Adds poison to all shield faces.",
	KIND.EXTRA_TOES: "Adds a reroll to empty faces.",
	KIND.HOLLOW_TEETH: "Adds heal to all attacks.",
}

func get_texture() -> Texture2D:
	var t = textures[kind]
	if not t:
		t = preload("res://assets/textures/dna.png")
	return t

func triggered(trigger_event: Enums.TRIGGERS, data: Dictionary, battle_state: BattleState) -> bool:
	match kind:
		KIND.ENLARGED_EYES:
			match trigger_event:
				Enums.TRIGGERS.COMBAT_START:
					for d in battle_state.deck:
						d.add_persistent_buff(Enums.PIP_TYPE.DEFEND, 1)
					return true
		KIND.SPIKY:
			match trigger_event:
				Enums.TRIGGERS.COMBAT_START:
					for d in battle_state.deck:
						d.add_persistent_buff(Enums.PIP_TYPE.ATTACK, -1)
					return true
				Enums.TRIGGERS.PRE_TAKE_DAMAGE:
					battle_state.enemy_hp -= data.shielded
					return true
		KIND.HARDENED_SCALES:
			match trigger_event:
				Enums.TRIGGERS.FIRST_ROLL, Enums.TRIGGERS.REROLL:
					if data.roll_result.die.get_total_pips(data.roll_result.face) == {}:
						data.roll_result.die.add_roll_pip(data.roll_result.face, Enums.PIP_TYPE.DEFEND, 1)
						return true
		KIND.HEIGHTENED_INSTINCTS:
			match trigger_event:
				Enums.TRIGGERS.FIRST_ROLL, Enums.TRIGGERS.REROLL:
					var face_attacks = []
					for f in 6:
						face_attacks.append(data.roll_result.die.get_total_pips(f).get(Enums.PIP_TYPE.ATTACK, 0))
					if face_attacks[data.roll_result.face] > 0 and face_attacks.max() == face_attacks[data.roll_result.face]:
						data.roll_result.die.add_roll_pip(data.roll_result.face, Enums.PIP_TYPE.ATTACK, face_attacks[data.roll_result.face])
						return true
		KIND.BUSTY:
			match trigger_event:
				Enums.TRIGGERS.COMBAT_START:
					for d in battle_state.deck:
						for i in 6:
							if d.get_total_pips(i) == {}:
								d.add_persistent_pip(i, Enums.PIP_TYPE.SLIME, 1)
					return true
		KIND.SLIMEY:
			match trigger_event:
				Enums.TRIGGERS.COMBAT_START:
					for d in battle_state.deck:
						for i in 6:
							if d.get_total_pips(i).get(Enums.PIP_TYPE.ATTACK, 0) > 0:
								d.add_persistent_pip(i, Enums.PIP_TYPE.SLIME, 1)
					return true
		KIND.SHELLIFIED:
			match trigger_event:
				Enums.TRIGGERS.FIRST_ROLL, Enums.TRIGGERS.REROLL:
					var face_defends = []
					for f in 6:
						face_defends.append(data.roll_result.die.get_total_pips(f).get(Enums.PIP_TYPE.DEFEND, 0))
					if face_defends[data.roll_result.face] > 0 and face_defends.max() == face_defends[data.roll_result.face]:
						data.roll_result.die.add_roll_pip(data.roll_result.face, Enums.PIP_TYPE.DEFEND, face_defends[data.roll_result.face])
						return true
		KIND.FUZZY:
			match trigger_event:
				Enums.TRIGGERS.COMBAT_START:
					for d in battle_state.deck:
						for i in 6:
							if d.get_total_pips(i).get(Enums.PIP_TYPE.DEFEND, 0) > 0:
								d.add_persistent_pip(i, Enums.PIP_TYPE.POISON, 1)
					return true
		KIND.EXTRA_TOES:
			match trigger_event:
				Enums.TRIGGERS.COMBAT_START:
					for d in battle_state.deck:
						for i in 6:
							if d.get_total_pips(i) == {}:
								d.add_persistent_pip(i, Enums.PIP_TYPE.REROLL, 1)
					return true
		KIND.HOLLOW_TEETH:
			match trigger_event:
				Enums.TRIGGERS.COMBAT_START:
					for d in battle_state.deck:
						for i in 6:
							if d.get_total_pips(i).get(Enums.PIP_TYPE.ATTACK, 0) > 0:
								d.add_persistent_pip(i, Enums.PIP_TYPE.HEAL, 1)
					return true
	
	return false
