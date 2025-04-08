extends Node2D
const DIE_SPRITE = preload("res://actors/die_sprite.tscn")
const BLOCK = preload("res://assets/items/block.tres")
const PUNCH = preload("res://assets/items/punch.tres")
const MUTATION_ICON = preload("res://actors/mutation_icon.tscn")
const BRICK = preload("res://assets/textures/brick.png")
const BROWN_BRICKS = preload("res://assets/textures/brown_bricks.png")

@export var hand_width: float = 100.0
@export var rolled_width: float = 100.0

var battle_state: BattleState = BattleState.new()

var _hand_tween: Tween

@onready var hand: Node2D = %Hand
@onready var rolled: Node2D = %Rolled
@onready var enemy_intent: Node2D = %EnemyIntent

@onready var rerolls_label: Label = %RerollsLabel
@onready var enemy_sprite: Sprite2D = %EnemySprite
@onready var player_sprite: Sprite2D = %PlayerSprite
@onready var enemy_heart_label: Label = %EnemyHeartLabel
@onready var player_heart_label: Label = %PlayerHeartLabel
@onready var mutation_grid_container: GridContainer = %MutationGridContainer
@onready var popup_panel: Panel = %PopupPanel
@onready var popup_label: RichTextLabel = %PopupLabel
@onready var ok_button: Button = %OKButton
@onready var mana_label: Label = %ManaLabel
@onready var bg: TextureRect = $BG

@onready var hand_initial_position: Vector2 = hand.position

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	MusicMan.music(preload("res://assets/music/Underworld (Battle Theme) Final.ogg"))
	
	battle_state.changed.connect(_on_battle_state_changed)
	if not Globals.player_stats:
		return
	Globals.player_stats.changed.connect(_on_player_stats_changed)
	for eq in Globals.player_stats.equipment:
		for i in eq.count:
			battle_state.deck.append(BattleState.LayeredDie.new(eq))
	battle_state.deck.shuffle()
	if not battle_state.enemy:
		battle_state.enemy = load("res://assets/enemies/rat.tres")
	enemy_sprite.texture = battle_state.enemy.sprite
	
	battle_state.enemy.max_hp *= Globals.act + 1
	
	battle_state.enemy_hp = battle_state.enemy.max_hp
	
	for m in Globals.player_stats.mutations:
		var tr = MUTATION_ICON.instantiate()
		tr.texture = m.get_texture()
		mutation_grid_container.add_child(tr)
	
	match battle_state.enemy.action_mode:
		Enums.ENEMY_ACTION_MODE.LOOP:
			pass
		Enums.ENEMY_ACTION_MODE.RANDOM:
			var result = 0
			var roll = randf() ** (1.0 / battle_state.enemy.actions[0].random_weight)
			var jump = log(randf()) / log(roll)
			for i in range(1, battle_state.enemy.actions.size()):
				jump -= battle_state.enemy.actions[i].random_weight
				if jump <= 0.0:
					var t = roll ** battle_state.enemy.actions[i].random_weight
					roll = randf_range(t, 1.0) ** (1.0 / battle_state.enemy.actions[i].random_weight)
					result = i
					jump = log(randf()) / log(roll)
			battle_state.enemy_action_index = result
	
	_on_battle_state_changed()
	_trigger_event(Enums.TRIGGERS.COMBAT_START)
	start_turn()

func _on_player_stats_changed() -> void:
	player_heart_label.text = str(Globals.player_stats.health)

func _on_battle_state_changed() -> void:
	enemy_heart_label.text = str(battle_state.enemy_hp)
	rerolls_label.text = str(battle_state.rerolls)
	mana_label.text = str(battle_state.mana)
	
	for c in enemy_intent.get_children():
		c.queue_free()
	
	var intent = battle_state.enemy.actions[battle_state.enemy_action_index].action
	if battle_state.enemy_slime > 0:
		intent = Enums.ENEMY_ACTION.PASS
	
	match intent:
		Enums.ENEMY_ACTION.PASS:
			var s = preload("res://actors/intent_icon.tscn").instantiate()
			s.texture = preload("res://assets/textures/zzz.png")
			enemy_intent.add_child(s)
		Enums.ENEMY_ACTION.ATTACK:
			var s = preload("res://actors/intent_icon.tscn").instantiate()
			s.texture = preload("res://assets/textures/pip_attack.png")
			var dmg = battle_state.enemy_strength + battle_state.enemy.actions[battle_state.enemy_action_index].action_param
			s.get_node("Label").text = str(dmg)
			enemy_intent.add_child(s)
		Enums.ENEMY_ACTION.DEFEND:
			var s = preload("res://actors/intent_icon.tscn").instantiate()
			s.texture = preload("res://assets/textures/pip_shield.png")
			s.get_node("Label").text = str(battle_state.enemy.actions[battle_state.enemy_action_index].action_param)
			enemy_intent.add_child(s)
		Enums.ENEMY_ACTION.HEAL:
			var s = preload("res://actors/intent_icon.tscn").instantiate()
			s.texture = preload("res://assets/textures/pip_heal.png")
			s.get_node("Label").text = str(battle_state.enemy.actions[battle_state.enemy_action_index].action_param)
			enemy_intent.add_child(s)
		Enums.ENEMY_ACTION.STRENGTH:
			var s = preload("res://actors/intent_icon.tscn").instantiate()
			s.texture = preload("res://assets/textures/intent_strength.png")
			s.get_node("Label").text = str(battle_state.enemy.actions[battle_state.enemy_action_index].action_param)
			enemy_intent.add_child(s)
	
	if battle_state.mana == 0:
		if hand.position == hand_initial_position:
			_hand_tween = create_tween()
			hand.position.y += 1.0
			_hand_tween.tween_property(hand, "position:y", hand_initial_position.y + 50.0, 0.2)
	else:
		if hand.position != hand_initial_position:
			hand.position.y -= 1.0
			_hand_tween = create_tween()
			_hand_tween.tween_property(hand, "position:y", hand_initial_position.y, 0.2)

func _trigger_event(type: Enums.TRIGGERS, data: Dictionary = {}) -> void:
	print("_trigger_event(%s, %s)" % [Enums.TRIGGERS.find_key(type), data])
	for i in Globals.player_stats.mutations.size():
		var m = Globals.player_stats.mutations[i]
		if m.triggered(type, data, battle_state):
			mutation_grid_container.get_child(i).pulse()
	
	match type:
		Enums.TRIGGERS.FIRST_ROLL, Enums.TRIGGERS.REROLL:
			var pips = data.roll_result.die.get_total_pips(data.roll_result.face)
			for pip in pips:
				match pip:
					Enums.PIP_TYPE.REROLL:
						battle_state.rerolls += pips[pip]

func shuffle_discard() -> void:
	print("Shuffling discard back into deck.")
	battle_state.deck = battle_state.discard
	battle_state.discard = []

func start_turn() -> void:
	print("Starting turn.")
	
	battle_state.mana = Globals.player_stats.initial_mana
	battle_state.rerolls = Globals.player_stats.initial_rerolls
	
	for i in 5:
		if not draw_from_deck():
			break
	
	_trigger_event(Enums.TRIGGERS.TURN_START)

func draw_from_deck() -> bool:
	if battle_state.deck.is_empty():
		shuffle_discard()
	if battle_state.deck.is_empty():
		return false
	var die: BattleState.LayeredDie = battle_state.deck.pop_back()
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

func discard_die(die: BattleState.LayeredDie) -> void:
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
	
	die.clear_turn_pips()
	die.clear_roll_pips()
	
	var sprite: DieSprite = die.battle_sprite
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

func win() -> void:
	popup_panel.visible = true
	popup_label.text = "You win!"
	await ok_button.pressed
	Globals.player_nav_event = "battle_won"
	SceneGirl.pop_scene()

func lose() -> void:
	popup_panel.visible = true
	popup_label.text = "You lose..."
	await ok_button.pressed
	Globals.player_nav_event = "battle_lost"
	SceneGirl.pop_scene()

func _on_die_clicked(sprite: DieSprite) -> void:
	var die: BattleState.LayeredDie = sprite.die
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
		roll.die.clear_roll_pips()
		battle_state.mana -= 1
		_trigger_event(Enums.TRIGGERS.FIRST_ROLL, { roll_result = roll })
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
			battle_state.rerolls -= 1
			roll.die.clear_roll_pips()
			_trigger_event(Enums.TRIGGERS.REROLL, { roll_result = roll })

func _adjust_sprite_positions() -> void:
	var hand_spacing = mini(96.0, hand_width / hand.get_child_count())
	var hand_start = hand_width / 2.0 - (hand.get_child_count() - 1) / 2.0 * hand_spacing
	for i in hand.get_child_count():
		var p = Vector2(hand_start + hand_spacing * i, 0.0)
		create_tween().set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_OUT) \
			.tween_property(hand.get_child(i), "position", p, 0.2)
	var rolled_spacing = mini(96.0, rolled_width / rolled.get_child_count())
	var rolled_start = rolled_width / 2.0 - (rolled.get_child_count() - 1) / 2.0 * rolled_spacing
	for i in rolled.get_child_count():
		var p = Vector2(rolled_start + rolled_spacing * i, 0.0)
		create_tween().set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_OUT) \
			.tween_property(rolled.get_child(i), "position", p, 0.2)

func _on_go_button_pressed() -> void:
	_trigger_event(Enums.TRIGGERS.GO)
	
	var player_damaged: bool = false
	var enemy_damaged: bool = false
	
	for i in battle_state.roll_results.size():
		var r: BattleState.RollResult = battle_state.roll_results[i]
		var pips = r.die.get_total_pips(r.face)
		for type in pips:
			match type:
				Enums.PIP_TYPE.ATTACK:
					var blocked = mini(battle_state.enemy_shield, pips[type])
					battle_state.enemy_shield -= blocked
					var trigger = { damage = pips[type] - blocked }
					_trigger_event(Enums.TRIGGERS.PRE_DEAL_DAMAGE, trigger)
					battle_state.enemy_hp -= trigger.damage
					if trigger.damage > 0:
						enemy_damaged = true
					_trigger_event(Enums.TRIGGERS.POST_DEAL_DAMAGE, trigger)
				Enums.PIP_TYPE.DEFEND:
					battle_state.player_shield += pips[type]
				Enums.PIP_TYPE.HEAL:
					Globals.player_stats.health = mini(Globals.player_stats.health + pips[type], Globals.player_stats.max_health)
				Enums.PIP_TYPE.POISON:
					battle_state.enemy_poison += pips[type]
	
	battle_state.enemy_shield = 0
	
	if battle_state.enemy_poison > 0:
		battle_state.enemy_hp -= battle_state.enemy_poison
		battle_state.enemy_poison = floori(battle_state.enemy_poison / 2.0)
		enemy_damaged = true
	
	if battle_state.enemy_hp <= 0:
		win()
		return
	
	var enemy_action = battle_state.enemy.actions[battle_state.enemy_action_index]
	var enemy_action_action = enemy_action.action
	var enemy_action_param = enemy_action.action_param
	if battle_state.enemy_slime > 0:
		enemy_action_action = Enums.ENEMY_ACTION.PASS
		battle_state.enemy_slime = 0
	match enemy_action_action:
		Enums.ENEMY_ACTION.PASS:
			pass
		Enums.ENEMY_ACTION.ATTACK:
			var trigger = {
				damage = maxi(0, battle_state.enemy_strength + enemy_action_param - battle_state.player_shield),
				shielded = mini(battle_state.enemy_strength + enemy_action_param, battle_state.player_shield),
			}
			_trigger_event(Enums.TRIGGERS.PRE_TAKE_DAMAGE, trigger)
			Globals.player_stats.health -= trigger.damage
			if trigger.damage > 0:
				player_damaged = true
			_trigger_event(Enums.TRIGGERS.POST_TAKE_DAMAGE, trigger)
		Enums.ENEMY_ACTION.DEFEND:
			battle_state.enemy_shield += enemy_action_param
		Enums.ENEMY_ACTION.HEAL:
			battle_state.enemy_hp = mini(battle_state.enemy_hp + enemy_action_param, battle_state.enemy.max_hp)
		Enums.ENEMY_ACTION.STRENGTH:
			battle_state.enemy_strength += enemy_action_param
	battle_state.player_shield = 0
	match battle_state.enemy.action_mode:
		Enums.ENEMY_ACTION_MODE.LOOP:
			var i = battle_state.enemy_action_index + 1
			if i >= battle_state.enemy.actions.size():
				i = battle_state.enemy.action_loop_point
			battle_state.enemy_action_index = clampi(i, 0, battle_state.enemy.actions.size())
		Enums.ENEMY_ACTION_MODE.RANDOM:
			var result = 0
			var roll = randf() ** (1.0 / battle_state.enemy.actions[0].random_weight)
			var jump = log(randf()) / log(roll)
			for i in range(1, battle_state.enemy.actions.size()):
				jump -= battle_state.enemy.actions[i].random_weight
				if jump <= 0.0:
					var t = roll ** battle_state.enemy.actions[i].random_weight
					roll = randf_range(t, 1.0) ** (1.0 / battle_state.enemy.actions[i].random_weight)
					result = i
					jump = log(randf()) / log(roll)
			battle_state.enemy_action_index = result
	
	for i in battle_state.roll_results.size():
		var r: BattleState.RollResult = battle_state.roll_results[i]
		var pips = r.die.get_total_pips(r.face)
		for type in pips:
			match type:
				Enums.PIP_TYPE.SLIME:
					battle_state.enemy_slime += pips[type]
	
	if Globals.player_stats.health <= 0:
		lose()
		return
	
	if battle_state.enemy_hp <= 0:
		win()
		return
	
	if not Settings.disable_flashing and player_damaged:
		var t = create_tween()
		t.tween_method(func (x):
			bg.texture = BRICK if floori(x) % 2 == 0 else BROWN_BRICKS
		, 0.0, 10.0, 0.5)
		t.tween_callback(func (): bg.texture = BRICK)
	
	if enemy_damaged:
		var o = enemy_sprite.position
		var t = create_tween()
		t.tween_method(func (x):
			var i = floori(x) % 2
			enemy_sprite.position.x = o.x + (-10 if i == 0 else 10)
		, 0.0, 10.0, 0.5)
		t.tween_callback(func (): enemy_sprite.position = o)
	
	discard_all(battle_state.roll_results.map(func (x): return x.die))
	discard_all(battle_state.hand)
	
	start_turn()
