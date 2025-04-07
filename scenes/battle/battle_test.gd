extends Node2D

const BATTLE = preload("res://scenes/battle/battle.tscn")

@export var test_equipment: Array[StuffDie]

var battle: Node2D

func _ready() -> void:
	for k in Mutation.KIND.values():
		var mut = Mutation.new()
		mut.kind = k
		Globals.player_stats.mutations.append(mut)
	
	battle = BATTLE.instantiate()
	battle.battle_state.enemy = load("res://assets/enemies/rat.tres")
	add_child(battle)
	
