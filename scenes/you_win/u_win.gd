extends Node2D

func _ready() -> void:
	MusicMan.music(preload("res://assets/music/Daisy Chains (Lose Theme) Final.ogg"))
	Globals.reset()

func _on_button_pressed() -> void:
	SceneGirl.change_scene("res://scenes/main_menu/main_menu.tscn")
