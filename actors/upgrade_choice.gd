extends PanelContainer

signal clicked()

@onready var name_label: Label = $VBoxContainer/Name
@onready var texture_rect: TextureRect = $VBoxContainer/TextureRect
@onready var description: Label = $VBoxContainer/Description
@onready var die_splay_control: Control = %DieSplayControl

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed:
			clicked.emit()
