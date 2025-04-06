class_name Enemy
extends Resource

@export var max_hp: int = 5
@export var sprite: Texture2D = preload("res://assets/textures/rat.png")
@export var actions: Array[ActionSpec]
@export var action_mode: Enums.ENEMY_ACTION_MODE
@export var action_loop_point: int = 0
