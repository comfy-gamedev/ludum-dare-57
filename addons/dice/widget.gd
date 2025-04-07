@tool
extends HBoxContainer

@onready var texture_rect: TextureRect = $TextureRect
@onready var spin_box: SpinBox = $SpinBox

func _ready() -> void:
	texture_rect.modulate = Color(0.75, 0.75, 0.75, 1.0) if spin_box.value == 0.0 else Color.WHITE

func _on_spin_box_value_changed(value: float) -> void:
	texture_rect.modulate = Color(0.75, 0.75, 0.75, 1.0) if value == 0.0 else Color.WHITE
