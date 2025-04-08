extends Node2D

signal offer_selected(item)

const UPGRADE_CHOICE = preload("res://actors/upgrade_choice.tscn")

const ITEMS = [
	"res://assets/items/arm_warmers.tres",
	"res://assets/items/board.tres",
	"res://assets/items/clean_sock.tres",
	"res://assets/items/dagger.tres",
	"res://assets/items/dirty_sock.tres",
	"res://assets/items/diving_helmet.tres",
	"res://assets/items/empty_bottle_of_poison.tres",
	"res://assets/items/glass bottle.tres",
	"res://assets/items/hammer.tres",
	"res://assets/items/hardhat.tres",
	"res://assets/items/hi_vis_vest.tres",
	"res://assets/items/lead_pipe.tres",
	"res://assets/items/lead_pipe_with_nail.tres",
	"res://assets/items/manhole_cover.tres",
	"res://assets/items/overalls.tres",
	"res://assets/items/paddle.tres",
	"res://assets/items/pipe_wrench.tres",
	"res://assets/items/poison_dagger.tres",
	"res://assets/items/shiv.tres",
	"res://assets/items/sledgehammer.tres",
	"res://assets/items/slimy_lead_pipe.tres",
	"res://assets/items/traffic_cone.tres",
	"res://assets/items/trash_can_lid.tres",
	"res://assets/items/vitamins.tres",
	"res://assets/items/wet_gloves.tres",
	"res://assets/items/blank.tres",
	"res://assets/items/mana_ball.tres",
]

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
	for i in 3:
		var item: StuffDie = load(ITEMS.pick_random())
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
