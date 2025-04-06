extends Node2D

const BATTLE = preload("res://scenes/battle/battle.tscn")

@export var test_equipment: Array[StuffDie]

var battle: Node2D

func _ready() -> void:
	battle = BATTLE.instantiate()
	battle.battle_state.enemy = load("res://assets/enemies/rat.tres")
	add_child(battle)
	
