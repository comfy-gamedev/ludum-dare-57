extends Node2D

signal offer_selected(item)

const UPGRADE_CHOICE = preload("res://actors/upgrade_choice.tscn")

var reason: Enums.UPGRADE_REASON

@onready var options: HBoxContainer = %Options
@onready var label: Label = %Label
@onready var skip_button: Button = $VBoxContainer/SkipButton

var _chosen: StuffDie

func _ready() -> void:
	$VBoxContainer/SkipButton.grab_focus()
	label.text = "Choose an item to lose forever..."
	for i in 3:
		var item: StuffDie = Globals.player_stats.equipment.pick_random()
		var c = UPGRADE_CHOICE.instantiate()
		options.add_child(c)
		c.name_label.text = item.name
		c.texture_rect.texture = item.item_image
		c.description.hide()
		c.die.die = item
		c.clicked.connect(offer_selected.emit.bind(item))
	_chosen = await offer_selected
	label.text = "Choose a replacement..."
	skip_button.disabled = true
	for c in options.get_children():
		c.queue_free()
	var choices = ItemDB.pick_n(3)
	for i in choices.size():
		var item: StuffDie = choices[i]
		var c = UPGRADE_CHOICE.instantiate()
		options.add_child(c)
		c.name_label.text = item.name
		c.texture_rect.texture = item.item_image
		c.description.hide()
		c.die.die = item
		c.clicked.connect(_pick_item.bind(item))

func _pick_item(item: StuffDie) -> void:
	Globals.player_stats.equipment.erase(_chosen)
	Globals.player_stats.equipment.append(item)
	SceneGirl.pop_scene()

func _on_skip_button_pressed() -> void:
	SceneGirl.pop_scene()
