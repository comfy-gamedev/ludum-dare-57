extends Node2D

const BATTLE = preload("res://scenes/battle/battle.tscn")

@export var test_equipment: Array[StuffDie]

var battle: Node2D

func _ready() -> void:
	Globals.player_stats = PlayerStats.new()
	Globals.player_stats.equipment = test_equipment
	Globals.player_stats.initial_mana = 3
	Globals.player_stats.initial_rerolls = 1
	battle = BATTLE.instantiate()
	battle.battle_state.enemy = load("res://assets/enemies/rat.tres")
	add_child(battle)
	
