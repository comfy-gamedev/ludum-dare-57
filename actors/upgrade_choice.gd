extends PanelContainer

signal clicked()

@onready var texture_rect: TextureRect = %TextureRect
@onready var name_label: Label = %Name
@onready var description: Label = %Description

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed:
			clicked.emit()
