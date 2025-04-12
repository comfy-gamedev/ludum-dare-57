extends PanelContainer

signal clicked()

@export var enable_click: bool = true

var die: StuffDie = null:
	set(v):
		if die == v: return
		if die: die.changed.disconnect(_reconcile)
		die = v
		if die: die.changed.connect(_reconcile)
		_reconcile()

@onready var image: TextureRect = %Image
@onready var name_label: Label = %Name
@onready var die_splay_control: Control = %DieSplayControl

func _gui_input(event: InputEvent) -> void:
	if not enable_click:
		return
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			accept_event()
			clicked.emit()

func _reconcile() -> void:
	if not is_node_ready():
		return
	image.texture = die.item_image if die else null
	name_label.text = die.name if die else ""
	die_splay_control.die = die
