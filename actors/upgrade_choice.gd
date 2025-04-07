extends PanelContainer

signal clicked()

@onready var name_label: Label = $VBoxContainer/Name
@onready var texture_rect: TextureRect = $VBoxContainer/TextureRect
@onready var description: Label = $VBoxContainer/Description
@onready var splay_texture_rect: TextureRect = $VBoxContainer/SplayTextureRect
@onready var die: Node3D = $SubViewport/Die

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed:
			clicked.emit()
