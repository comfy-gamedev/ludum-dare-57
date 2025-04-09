class_name Battle
extends Node2D

const DIE_FACE_PIP = preload("res://actors/die_face_pip.tscn")
const DIE_SPRITE = preload("res://actors/die_sprite.tscn")
const BLOCK = preload("res://assets/items/block.tres")
const PUNCH = preload("res://assets/items/punch.tres")
const MUTATION_ICON = preload("res://actors/mutation_icon.tscn")
const BRICK = preload("res://assets/textures/brick.png")
const BROWN_BRICKS = preload("res://assets/textures/brown_bricks.png")

@export var hand_width: float = 100.0
@export var rolled_width: float = 100.0

var state: BattleState = BattleState.new()

var _hand_tween: Tween

@onready var hand: Node2D = %Hand
@onready var rolled: Node2D = %Rolled
@onready var enemy_intent: Node2D = %EnemyIntent

@onready var player_screen: CharacterScreen = %PlayerScreen
@onready var enemy_screen: CharacterScreen = %EnemyScreen

@onready var mutation_grid_container: GridContainer = %MutationGridContainer
@onready var popup_panel: Panel = %PopupPanel
@onready var popup_label: RichTextLabel = %PopupLabel
@onready var ok_button: Button = %OKButton
@onready var bg: TextureRect = $BG

@onready var hand_initial_position: Vector2 = hand.position

@onready var clicky_sound: AudioStreamPlayer = $ClickySound
@onready var creepy_crunchy: AudioStreamPlayer = $CreepyCrunchy
@onready var dice_roll: AudioStreamPlayer = $DiceRoll
@onready var hit_impact_crunch: AudioStreamPlayer = $HitImpactCrunch
@onready var hit_impact_crunch_oof: AudioStreamPlayer = $HitImpactCrunchOof
@onready var impacts = [
	$HitImpactCrunch,
	$HitImpactCrunchOof,
	$Ughhit,
]
@onready var longer_die_roll_2: AudioStreamPlayer = $LongerDieRoll2
@onready var longer_die_roll: AudioStreamPlayer = $LongerDieRoll
@onready var ughhit: AudioStreamPlayer = $Ughhit


func _ready() -> void:
	MusicMan.music(preload("res://assets/music/Underworld (Battle Theme) Final.ogg"))
	
	state.enemy_intent_changed.connect(_on_state_enemy_intent_changed)
	state.player_state.changed.connect(_on_player_state_changed)
	state.player_state.pre_damage.connect(_on_player_state_pre_damage)
	state.player_state.post_damage.connect(_on_player_state_post_damage)
	state.enemy_state.changed.connect(_on_enemy_state_changed)
	state.enemy_state.pre_damage.connect(_on_enemy_state_pre_damage)
	state.enemy_state.post_damage.connect(_on_enemy_state_post_damage)
	
	if not Globals.player_stats:
		return
	
	state.player_state.hp = Globals.player_stats.health
	
	for eq in Globals.player_stats.equipment:
		for i in eq.count:
			state.deck.append(LayeredDie.new(eq))
	state.deck.shuffle()
	
	if not state.enemy:
		state.enemy = load("res://assets/enemies/rat.tres").duplicate()
	
	enemy_screen.sprite.texture = state.enemy.sprite
	
	state.enemy.max_hp *= 1 + (Globals.act * 0.2)
	
	state.enemy_state.hp = state.enemy.max_hp
	
	player_screen.character_state = state.player_state
	enemy_screen.character_state = state.enemy_state
	
	for m in Globals.player_stats.mutations:
		var tr = MUTATION_ICON.instantiate()
		tr.texture = m.get_texture()
		mutation_grid_container.add_child(tr)
	
	_trigger_event(Enums.TRIGGER.COMBAT_START)
	start_turn()

func _trigger_event(type: Enums.TRIGGER, data: Dictionary = {}) -> void:
	print("_trigger_event(%s, %s)" % [Enums.TRIGGER.find_key(type), data])
	for i in Globals.player_stats.mutations.size():
		var m = Globals.player_stats.mutations[i]
		if m.triggered(type, data, self):
			mutation_grid_container.get_child(i).pulse()

func shuffle_discard() -> void:
	print("Shuffling discard back into deck.")
	state.deck = state.discard
	state.discard = []

func start_turn() -> void:
	print("Starting turn.")
	
	state.player_state.mana = Globals.player_stats.initial_mana
	state.player_state.rerolls = Globals.player_stats.initial_rerolls
	
	discard_all(state.roll_results)
	discard_all(state.hand)
	
	for i in 5:
		if not draw_from_deck():
			break
	
	state.prepare_enemy_act()
	
	_trigger_event(Enums.TRIGGER.TURN_START)

func draw_from_deck() -> bool:
	if state.deck.is_empty():
		shuffle_discard()
	if state.deck.is_empty():
		return false
	var die: LayeredDie = state.deck.pop_back()
	print("Drawing die ", die, " from deck.")
	state.hand.append(die)
	var sprite = DIE_SPRITE.instantiate()
	sprite.die = die
	sprite.animation_mode = DieSprite.AnimMode.FLOATING
	hand.add_child(sprite)
	sprite.position.x = float(sprite.get_index()) / float(state.hand.size() - 1) * hand_width
	sprite.clicked.connect(_on_die_clicked.bind(sprite))
	sprite.random_tap()
	_adjust_sprite_positions()
	return true

func discard_die(die: LayeredDie) -> void:
	var i = state.roll_results.find(die)
	if i != -1:
		print("Discarding die ", die, " from roll_results.")
		state.roll_results.remove_at(i)
	elif die in state.hand:
		print("Discarding die ", die, " from hand.")
		state.hand.erase(die)
	elif die in state.deck:
		print("Discarding die ", die, " from deck.")
		state.deck.erase(die)
	else:
		print("Discarding die ", die, " NOT FOUND.")
	
	state.discard.append(die)
	
	die.clear_turn_pips()
	die.clear_roll_pips()
	
	var sprite: DieSprite = die.battle_sprite
	if is_instance_valid(sprite):
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

func apply_die_instants(die: LayeredDie, face: int = -1) -> void:
	if face == -1:
		face = die.rolled_face
	var pips = die.get_total_pips(face)
	for pip in pips:
		match pip:
			Enums.PIP_TYPE.REROLL:
				state.player_state.rerolls += pips[pip]
			Enums.PIP_TYPE.DRAW:
				draw_from_deck()
			Enums.PIP_TYPE.MANA:
				state.player_state.mana += pips[pip]
			Enums.PIP_TYPE.INSTANT_ATTACK:
				state.enemy_state.deal_damage(pips[pip])
			Enums.PIP_TYPE.INSTANT_PAIN:
				state.player_state.deal_damage(pips[pip])

func apply_die(die: LayeredDie, face: int = -1) -> void:
	if face == -1:
		face = die.rolled_face
	var pips = die.get_total_pips(face)
	for type in pips:
		match type:
			Enums.PIP_TYPE.ATTACK:
				state.enemy_state.deal_damage(pips[type])
			Enums.PIP_TYPE.HEAL:
				state.player_state.hp = mini(state.player_state.hp + pips[type], Globals.player_stats.max_health)
			Enums.PIP_TYPE.DEFEND:
				state.player_state.add_status_pip(Enums.PIP_TYPE.DEFEND, pips[type])
			Enums.PIP_TYPE.POISON:
				state.enemy_state.add_status_pip(Enums.PIP_TYPE.POISON, pips[type])
			Enums.PIP_TYPE.SLIME:
				state.enemy_state.add_status_pip(Enums.PIP_TYPE.SLIME, pips[type])

func _on_die_clicked(sprite: DieSprite) -> void:
	if sprite.is_rolling(): return
	var die: LayeredDie = sprite.die
	var trigger = null
	
	if state.player_state.mana > 0 and die in state.hand:
		state.player_state.mana -= 1
		die.rolled_face = randi_range(0, 5)
		state.roll_results.append(die)
		state.hand.erase(die)
		sprite.reparent(rolled)
		_adjust_sprite_positions()
		trigger = Enums.TRIGGER.FIRST_ROLL
	elif state.player_state.rerolls > 0 and die in state.roll_results:
		state.player_state.rerolls -= 1
		die.rolled_face = randi_range(0, 5)
		trigger = Enums.TRIGGER.REROLL
	
	if trigger != null:
		die.clear_roll_pips()
		dice_roll.play()
		await die.battle_sprite.roll()
		_trigger_event(trigger, { roll_result = die })
		apply_die_instants(die)

func _adjust_sprite_positions() -> void:
	var hand_spacing = minf(96.0, hand_width / hand.get_child_count())
	var hand_start = hand_width / 2.0 - (hand.get_child_count() - 1) / 2.0 * hand_spacing
	for i in hand.get_child_count():
		var p = Vector2(hand_start + hand_spacing * i, 0.0)
		create_tween().set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_OUT) \
			.tween_property(hand.get_child(i), "position", p, 0.2)
	var rolled_spacing = minf(96.0, rolled_width / rolled.get_child_count())
	var rolled_start = rolled_width / 2.0 - (rolled.get_child_count() - 1) / 2.0 * rolled_spacing
	for i in rolled.get_child_count():
		var p = Vector2(rolled_start + rolled_spacing * i, 0.0)
		create_tween().set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_OUT) \
			.tween_property(rolled.get_child(i), "position", p, 0.2)

func _unhandled_key_input(event: InputEvent) -> void:
	if not OS.has_feature("debug"):
		set_process_unhandled_key_input(false)
		return
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_KP_9:
			win()

func _on_go_button_pressed() -> void:
	_trigger_event(Enums.TRIGGER.GO)
	
	var player_inital_hp: int = state.player_state.hp
	var enemy_initial_hp: int = state.enemy_state.hp
	
	# Player action.
	for i in state.roll_results.size():
		apply_die(state.roll_results[i])
	
	state.enemy_state.set_status_pip(Enums.PIP_TYPE.DEFEND, 0)
	
	# Enemy poison.
	if state.enemy_state.get_status_pip(Enums.PIP_TYPE.POISON) > 0:
		state.enemy_state.deal_damage(state.enemy_state.get_status_pip(Enums.PIP_TYPE.POISON))
		state.enemy_state.set_status_pip(Enums.PIP_TYPE.POISON, floori(state.enemy_state.get_status_pip(Enums.PIP_TYPE.POISON) / 2.0))
	
	# Early victory check.
	if state.enemy_state.hp <= 0:
		win()
		return
	
	# Player poison.
	if state.player_state.get_status_pip(Enums.PIP_TYPE.POISON) > 0:
		state.player_state.deal_damage(state.player_state.get_status_pip(Enums.PIP_TYPE.POISON))
		state.player_state.set_status_pip(Enums.PIP_TYPE.POISON, floori(state.player_state.get_status_pip(Enums.PIP_TYPE.POISON) / 2.0))
	
	# Enemy action.
	match state.enemy_act.action:
		Enums.ENEMY_ACTION.PASS:
			pass
		Enums.ENEMY_ACTION.ATTACK:
			state.player_state.deal_damage(state.enemy_state.get_status_pip(Enums.PIP_TYPE.STRENGTH) + state.enemy_act.param)
		Enums.ENEMY_ACTION.DEFEND:
			state.enemy_state.add_status_pip(Enums.PIP_TYPE.DEFEND, state.enemy_act.param)
		Enums.ENEMY_ACTION.HEAL:
			state.enemy_state.hp = mini(state.enemy_state.hp + state.enemy_act.param, state.enemy.max_hp)
		Enums.ENEMY_ACTION.STRENGTH:
			state.enemy_state.add_status_pip(Enums.PIP_TYPE.STRENGTH, state.enemy_act.param)
	
	state.player_state.set_status_pip(Enums.PIP_TYPE.DEFEND, 0)
	
	# Check loss.
	if state.player_state.hp <= 0:
		lose()
		return
	
	# Check victory.
	if state.enemy_state.hp <= 0:
		win()
		return
	
	# Enemy damaged.
	if state.enemy_state.hp != enemy_initial_hp:
		enemy_screen.shake()
		impacts.pick_random().play()
	
	# Player damaged.
	if state.player_state.hp != player_inital_hp:
		player_screen.shake()
		impacts.pick_random().play()
		if not Settings.disable_flashing:
			var t = create_tween()
			t.tween_method(func (x):
				bg.texture = BRICK if floori(x) % 2 == 0 else BROWN_BRICKS
			, 0.0, 10.0, 0.5)
			t.tween_callback(func ():
				bg.texture = BRICK)
	
	start_turn()

func _on_state_enemy_intent_changed() -> void:
	for c in enemy_intent.get_children():
		c.queue_free()
	
	var intent = state.enemy_act.action
	var intent_value = state.enemy_act.param
	
	var pip = DIE_FACE_PIP.instantiate()
	enemy_intent.add_child(pip)
	pip.size *= 2
	pip.position = -pip.size/2.0
	pip.label.pivot_offset = Vector2(32, 32)
	pip.label.scale = Vector2(2, 2)
	
	match intent:
		Enums.ENEMY_ACTION.PASS:
			pip.texture = preload("res://assets/textures/zzz.png")
		Enums.ENEMY_ACTION.ATTACK:
			pip.texture = Enums.PIP_TEXTURES[Enums.PIP_TYPE.ATTACK]
			var plus = state.enemy_state.get_status_pip(Enums.PIP_TYPE.STRENGTH)
			intent_value = plus + state.enemy_act.param
			if plus != 0:
				pip.label.label_settings.font_color = Color("85b396")
		Enums.ENEMY_ACTION.DEFEND:
			pip.texture = Enums.PIP_TEXTURES[Enums.PIP_TYPE.DEFEND]
		Enums.ENEMY_ACTION.HEAL:
			pip.texture = Enums.PIP_TEXTURES[Enums.PIP_TYPE.HEAL]
		Enums.ENEMY_ACTION.STRENGTH:
			pip.texture = Enums.PIP_TEXTURES[Enums.PIP_TYPE.STRENGTH]
	
	if intent_value > 1:
		pip.label.text = str(intent_value)
		pip.label.show()
	

func _on_player_state_changed() -> void:
	Globals.player_stats.health = state.player_state.hp
	
	if state.player_state.mana == 0:
		if hand.position == hand_initial_position:
			_hand_tween = create_tween()
			hand.position.y += 1.0
			_hand_tween.tween_property(hand, "position:y", hand_initial_position.y + 50.0, 0.2)
	else:
		if hand.position != hand_initial_position:
			hand.position.y -= 1.0
			_hand_tween = create_tween()
			_hand_tween.tween_property(hand, "position:y", hand_initial_position.y, 0.2)

func _on_player_state_pre_damage(data: Dictionary) -> void:
	_trigger_event(Enums.TRIGGER.PRE_TAKE_DAMAGE, data)

func _on_player_state_post_damage(data: Dictionary) -> void:
	_trigger_event(Enums.TRIGGER.POST_TAKE_DAMAGE, data)

func _on_enemy_state_changed() -> void:
	pass

func _on_enemy_state_pre_damage(data: Dictionary) -> void:
	_trigger_event(Enums.TRIGGER.PRE_DEAL_DAMAGE, data)

func _on_enemy_state_post_damage(data: Dictionary) -> void:
	_trigger_event(Enums.TRIGGER.POST_DEAL_DAMAGE, data)
