@tool
extends Control
const EDITOR = preload("res://addons/dice/editor.tscn")
@onready var option_button: OptionButton = %OptionButton
@onready var h_box_container: HBoxContainer = %HBoxContainer
@onready var count_spin_box: SpinBox = $VBoxContainer/HBoxContainer2/CountSpinBox

var item_dir = "res://assets/items/"

var items = []

var item_path: String
var item: StuffDie

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if EditorInterface.get_edited_scene_root() == self:
		return
	for f in DirAccess.get_files_at(item_dir):
		items.append(item_dir.path_join(f))
		option_button.add_item(f)
		option_button.set_item_metadata(option_button.item_count - 1, item_dir.path_join(f))



func _on_option_button_item_selected(index: int) -> void:
	if EditorInterface.get_edited_scene_root() == self:
		return
	item_path = option_button.get_item_metadata(index)
	item = load(item_path)
	EditorInterface.inspect_object(item)
	count_spin_box.value = item.count
	for c in h_box_container.get_children():
		c.queue_free()
	for i in 6:
		var c = EDITOR.instantiate()
		c.die = item
		c.face = i
		h_box_container.add_child(c)


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

