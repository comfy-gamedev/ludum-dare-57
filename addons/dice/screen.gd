@tool
extends Control
const EDITOR = preload("res://addons/dice/editor.tscn")
@onready var option_button: OptionButton = %OptionButton
@onready var tools: GridContainer = %Tools
@onready var die_splay_control: Control = %DieSplayControl
@onready var count_spin_box: SpinBox = %CountSpinBox

var item_dir = "res://assets/items/"

var items = []

var item_path: String
var item: StuffDie

var current_tool: Dictionary = {} # {} | { pip: PIP_TYPE }

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if EditorInterface.get_edited_scene_root() == self:
		return
	for f in DirAccess.get_files_at(item_dir):
		items.append(item_dir.path_join(f))
		option_button.add_item(f)
		option_button.set_item_metadata(option_button.item_count - 1, item_dir.path_join(f))
	_on_option_button_item_selected(0)
	var btn_group = ButtonGroup.new()
	for i in Enums.PIP_TYPE.values():
			if i not in Enums.PIP_TEXTURES:
				continue
			var btn = Button.new()
			btn.toggle_mode = true
			btn.button_group = btn_group
			btn.icon = Enums.PIP_TEXTURES[i]
			btn.tooltip_text = Enums.PIP_TYPE.find_key(i)
			tools.add_child(btn)
			btn.toggled.connect(func (pressed: bool):
				if pressed:
					current_tool = { pip = i }
				else:
					current_tool = {})
	for i in die_splay_control.die_faces.size():
		var f = die_splay_control.die_faces[i]
		f.gui_input.connect(func (event: InputEvent):
			if not item:
				return
			if event is InputEventMouseButton:
				if event.pressed:
					match event.button_index:
						MOUSE_BUTTON_LEFT:
							if "pip" in current_tool:
								item.faces[i].set_pips(current_tool.pip, item.faces[i].get_pips(current_tool.pip) + 1)
								ResourceSaver.save(item)
						MOUSE_BUTTON_RIGHT:
							if event.shift_pressed:
								item.faces[i].pips = {}
							elif "pip" in current_tool:
								item.faces[i].set_pips(current_tool.pip, item.faces[i].get_pips(current_tool.pip) - 1)
								ResourceSaver.save(item)
		)

func _on_option_button_item_selected(index: int) -> void:
	if EditorInterface.get_edited_scene_root() == self:
		return
	item_path = option_button.get_item_metadata(index)
	item = load(item_path)
	EditorInterface.inspect_object(item)
	count_spin_box.value = item.count
	die_splay_control.die = item


func _on_count_spin_box_value_changed(value: float) -> void:
	if not item:
		return
	item.count = value
	ResourceSaver.save(item)


func _on_visibility_changed() -> void:
	if EditorInterface.get_edited_scene_root() == self:
		return
	if visible and option_button:
		option_button.clear()
		for f in DirAccess.get_files_at(item_dir):
			items.append(item_dir.path_join(f))
			option_button.add_item(f)
			option_button.set_item_metadata(option_button.item_count - 1, item_dir.path_join(f))

