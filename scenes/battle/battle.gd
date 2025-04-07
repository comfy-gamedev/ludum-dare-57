extends Node2D
const DIE_SPRITE = preload("res://actors/die_sprite.tscn")
const BLOCK = preload("res://assets/items/block.tres")
const PUNCH = preload("res://assets/items/punch.tres")

@export var hand_width: float = 100.0
@export var rolled_width: float = 100.0

var battle_state: BattleState = BattleState.new()

@onready var hand: Node2D = $Hand
@onready var rolled: Node2D = $Rolled
@onready var rerolls_label: Label = %RerollsLabel
@onready var enemy_sprite: Sprite2D = %EnemySprite
@onready var player_sprite: Sprite2D = %PlayerSprite
@onready var enemy_heart_label: Label = %EnemyHeartLabel
@onready var player_heart_label: Label = %PlayerHeartLabel

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	battle_state.changed.connect(_on_battle_state_changed)
	if not Globals.player_stats:
		return
	Globals.player_stats.changed.connect(_on_player_stats_changed)
	for eq in Globals.player_stats.equipment:
		for i in eq.count:
			battle_state.deck.append(eq.duplicate())
	enemy_sprite.texture = battle_state.enemy.sprite
	battle_state.enemy_hp = battle_state.enemy.max_hp
	_turn_start()

func _on_player_stats_changed() -> void:
	player_heart_label.text = str(Globals.player_stats.health)

func _on_battle_state_changed() -> void:
	enemy_heart_label.text = str(battle_state.enemy_hp)

func _turn_start() -> void:
	battle_state.mana = Globals.player_stats.initial_mana
	battle_state.rerolls = Globals.player_stats.initial_rerolls
	
	for i in 5:
		if not draw_from_deck():
			break

func shuffle_discard() -> void:
	print("Shuffling discard back into deck.")
	battle_state.deck = battle_state.discard
	battle_state.discard = []

func draw_from_deck() -> bool:
	if battle_state.deck.is_empty():
		shuffle_discard()
	if battle_state.deck.is_empty():
		return false
	var die: StuffDie = battle_state.deck.pop_back()
	print("Drawing die ", die, " from deck.")
	battle_state.hand.append(die)
	var sprite = DIE_SPRITE.instantiate()
	sprite.die = die
	sprite.animation_mode = DieSprite.AnimMode.FLOATING
	hand.add_child(sprite)
	sprite.position.x = float(sprite.get_index()) / float(battle_state.hand.size() - 1) * hand_width
	sprite.clicked.connect(_on_die_clicked.bind(sprite))
	_adjust_sprite_positions()
	return true

func discard_die(die: StuffDie) -> void:
	var i = battle_state.roll_results.find_custom(func (x): return x.die == die)
	if i != -1:
		print("Discarding die ", die, " from roll_results.")
		battle_state.roll_results.remove_at(i)
	elif die in battle_state.hand:
		print("Discarding die ", die, " from hand.")
		battle_state.hand.erase(die)
	elif die in battle_state.deck:
		print("Discarding die ", die, " from deck.")
		battle_state.deck.erase(die)
	else:
		print("Discarding die ", die, " NOT FOUND.")
	battle_state.discard.append(die)
	
	var sprite: DieSprite = die._battle_sprite
	if not is_instance_valid(sprite):
		return
	sprite.reparent(self)
	var tween = create_tween()
	tween.tween_property(sprite, "position", Vector2(900, 500), 0.2)
	await tween.finished
	sprite.queue_free()

func discard_all(dice: Array) -> void:
	for d in dice.duplicate():
		print("Discard-all die ", d, "...")
		discard_die(d)

func _on_die_clicked(sprite: DieSprite) -> void:
	var die: StuffDie = sprite.die
	if battle_state.mana > 0 and die in battle_state.hand:
		var roll = BattleState.RollResult.new(die, randi_range(0, 5))
		battle_state.roll_results.append(roll)
		battle_state.hand.erase(die)
		sprite.reparent(rolled)
		sprite.animation_mode = DieSprite.AnimMode.NONE
		var orientation := Quaternion(
			sprite.die_node.get_face_orientation(roll.face))
		var orig = sprite.get_combined_rotation()
		create_tween().tween_method(func (x):
			sprite.die_rotation = orig.slerp(orientation, x)
		, 0.0, 1.0, 0.2)
		_adjust_sprite_positions()
	elif battle_state.rerolls > 0:
		var f = battle_state.roll_results.find_custom(func (x): return x.die == die)
		if f != -1:
			var roll = battle_state.roll_results[f]
			roll.face = randi_range(0, 5)
			var orientation := Quaternion(
				sprite.die_node.get_face_orientation(roll.face))
			var orig = sprite.get_combined_rotation()
			create_tween().tween_method(func (x):
				sprite.die_rotation = orig.slerp(orientation, x)
			, 0.0, 1.0, 0.2)

func _adjust_sprite_positions() -> void:
	for i in hand.get_child_count():
		var p = Vector2(float(i) / float(hand.get_child_count() - 1) * hand_width, 0.0)
		if is_nan(p.x): p.x = 0.0
		create_tween().set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_OUT) \
			.tween_property(hand.get_child(i), "position", p, 0.2)
	for i in rolled.get_child_count():
		var p = Vector2(float(i) / float(rolled.get_child_count() - 1) * rolled_width, 0.0)
		if is_nan(p.x): p.x = 0.0
		create_tween().set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_OUT) \
			.tween_property(rolled.get_child(i), "position", p, 0.2)

func _on_go_button_pressed() -> void:
	for i in Globals.PlayerStats.mutations:
		i.triggered(Mutation.TRIGGERS.ROLL_DIE, battle_state)
	for i in battle_state.roll_results.size():
		var r = battle_state.roll_results[i]
		var face = r.die.faces[r.face]
		for type in face.pips:
			match type:
				Enums.PIP_TYPE.ATTACK:
					for j in Globals.PlayerStats.mutations:
						j.triggered(Mutation.TRIGGERS.DEAL_DAMAGE, battle_state)
					battle_state.enemy_hp -= face.pips[type]
				Enums.PIP_TYPE.DEFEND:
					battle_state.player_shield += face.pips[type]
	var enemy_action = battle_state.enemy.actions[battle_state.enemy_action_index]
	match enemy_action.action:
		Enums.ENEMY_ACTION.PASS:
			pass
		Enums.ENEMY_ACTION.ATTACK:
			var dmg = enemy_action.action_param - battle_state.player_shield
			if dmg > 0:
				for i in Globals.PlayerStats.mutations:
					i.triggered(Mutation.TRIGGERS.TAKE_DAMAGE, battle_state)
				Globals.player_stats.health -= dmg
	match battle_state.enemy.action_mode:
		Enums.ENEMY_ACTION_MODE.LOOP:
			battle_state.enemy_action_index += 1
			if battle_state.enemy_action_index >= battle_state.enemy.actions.size():
				battle_state.enemy_action_index = battle_state.enemy.action_loop_point
		Enums.ENEMY_ACTION_MODE.RANDOM:
			battle_state.enemy_action_index = 0
			var roll = randf() ** (1.0 / battle_state.enemy.actions[0].random_weight)
			var jump = log(randf()) / log(roll)
			for i in range(1, battle_state.enemy.actions.size()):
				jump -= battle_state.enemy.actions[i].random_weight
				if jump <= 0.0:
					var t = roll ** battle_state.enemy.actions[i].random_weight
					roll = randf_range(t, 1.0) ** (1.0 / battle_state.enemy.actions[i].random_weight)
					battle_state.enemy_action_index = i
					jump = log(randf()) / log(roll)
	discard_all(battle_state.roll_results.map(func (x): return x.die))
	discard_all(battle_state.hand)
	if battle_state.enemy_hp <= 0:
		SceneGirl.pop_scene()
		return
	if Globals.player_stats.health <= 0:
		SceneGirl.pop_scene()
		return
	for i in 5:
		if not draw_from_deck():
			break
