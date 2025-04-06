extends Node2D

@export var test_equipment: Array[StuffDie]

@onready var battle_test: Node2D = $"."

func _enter_tree() -> void:
	Globals.player_stats = PlayerStats.new()
	Globals.player_stats.equipment = test_equipment
