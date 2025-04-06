extends Node2D

@onready var card1 = $VBoxContainer/BoxContainer/HBoxContainer/ColorRect
@onready var card2 = $VBoxContainer/BoxContainer/HBoxContainer/ColorRect2
@onready var card3 = $VBoxContainer/BoxContainer/HBoxContainer/ColorRect3

func _ready() -> void:
	$VBoxContainer/Button.grab_focus()

func _on_color_rect_gui_input(event: InputEvent) -> void:
	if event.is_action("ui_accept"):
		SceneGirl.change_scene("res://scenes/navigation/navigation.tscn")


func _on_color_rect_2_gui_input(event: InputEvent) -> void:
	if event.is_action("ui_accept"):
		SceneGirl.change_scene("res://scenes/navigation/navigation.tscn")


func _on_color_rect_3_gui_input(event: InputEvent) -> void:
	if event.is_action("ui_accept"):
		SceneGirl.change_scene("res://scenes/navigation/navigation.tscn")


func _on_button_pressed() -> void:
	SceneGirl.change_scene("res://scenes/navigation/navigation.tscn")


func _on_color_rect_focus_entered() -> void:
	card1.color = Color("646464")


func _on_color_rect_focus_exited() -> void:
	card1.color = Color("646464e4")


func _on_color_rect_2_focus_entered() -> void:
	card2.color = Color("646464")


func _on_color_rect_2_focus_exited() -> void:
	card2.color = Color("646464e4")


func _on_color_rect_3_focus_entered() -> void:
	card3.color = Color("646464")


func _on_color_rect_3_focus_exited() -> void:
	card3.color = Color("646464e4")
