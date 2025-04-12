extends Node2D

const UPGRADE_CHOICE = preload("res://actors/upgrade_choice.tscn")
const DIE_CARD = preload("res://actors/die_card.tscn")

var ITEM_RATES = {
	Enums.UPGRADE_REASON.TREASURE: {
		Enums.ITEM_RARITY.COMMON: 1.0,
		Enums.ITEM_RARITY.UNCOMMON: 0.4,
	},
	Enums.UPGRADE_REASON.ENEMY: {
		Enums.ITEM_RARITY.COMMON: 1.0,
		Enums.ITEM_RARITY.UNCOMMON: 0.3,
		Enums.ITEM_RARITY.RARE: 0.05,
	},
	Enums.UPGRADE_REASON.ELITE: {
		Enums.ITEM_RARITY.COMMON: 1.1,
		Enums.ITEM_RARITY.UNCOMMON: 1.0,
		Enums.ITEM_RARITY.RARE: 0.2,
	},
	Enums.UPGRADE_REASON.BOSS: {
		Enums.ITEM_RARITY.COMMON: 1.1,
		Enums.ITEM_RARITY.ULTRA_RARE: 1.0,
	},
}

var reason: Enums.UPGRADE_REASON

@onready var options: HBoxContainer = %Options
@onready var label: Label = %Label

func _ready() -> void:
	$VBoxContainer/SkipButton.grab_focus()
	match reason:
		Enums.UPGRADE_REASON.TREASURE,\
		Enums.UPGRADE_REASON.ENEMY,\
		Enums.UPGRADE_REASON.ELITE,\
		Enums.UPGRADE_REASON.BOSS:
			label.text = "Choose An Item!"
			var choices = ItemDB.pick_n(3, ITEM_RATES[reason])
			for i in choices.size():
				var item: StuffDie = choices[i]
				var c = DIE_CARD.instantiate()
				options.add_child(c)
				c.die = item
				c.clicked.connect(_pick_item.bind(item))
		Enums.UPGRADE_REASON.MUTATION:
			label.text = "Choose A Mutation!"
			for i in 2:
				var mut = Mutation.KIND.values().pick_random()
				var c = UPGRADE_CHOICE.instantiate()
				options.add_child(c)
				c.name_label.text = Mutation.names[mut]
				c.texture_rect.texture = Mutation.textures[mut]
				c.splay_texture_rect.hide()
				c.description.text = Mutation.descriptions[mut]
				c.description.autowrap_mode = TextServer.AUTOWRAP_WORD
				c.description.custom_minimum_size = Vector2(400, 0)
				c.clicked.connect(_pick_mutation.bind(mut))

func _pick_item(item: StuffDie) -> void:
	Globals.player_stats.equipment.append(item)
	SceneGirl.pop_scene()

func _pick_mutation(mut: Mutation.KIND) -> void:
	var m = Mutation.new()
	m.kind = mut
	Globals.player_stats.mutations.append(m)
	SceneGirl.pop_scene()

func _on_skip_button_pressed() -> void:
	SceneGirl.pop_scene()
