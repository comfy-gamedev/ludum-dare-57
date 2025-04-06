extends Node2D
const DIE_SPRITE = preload("res://actors/die_sprite.tscn")

@export var hand_width: float = 100.0

var battle_state: BattleState = BattleState.new()

@onready var hand: Node2D = $Hand

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if not Globals.player_stats:
		return
	for eq in Globals.player_stats.equipment:
		for i in eq.count:
			battle_state.deck.append(eq)
	_turn_start()

func _turn_start() -> void:
	battle_state.mana = Globals.player_stats.initial_mana
	battle_state.rerolls = Globals.player_stats.initial_rerolls
	
	for i in 5:
		if battle_state.deck.is_empty():
			battle_state.deck = battle_state.discard
			battle_state.discard = []
		if battle_state.deck.is_empty():
			break
		battle_state.hand.append(battle_state.deck.pop_back())
	
	_reconcile()

func _reconcile() -> void:
	for c in hand.get_children():
		c.queue_free()
	for i in battle_state.hand.size():
		var sprite = DIE_SPRITE.instantiate()
		sprite.die = battle_state.hand[i]
		sprite.animation_mode = DieSprite.AnimMode.FLOATING
		sprite.position.x = float(i) / float(battle_state.hand.size() - 1) * hand_width
		hand.add_child(sprite)
