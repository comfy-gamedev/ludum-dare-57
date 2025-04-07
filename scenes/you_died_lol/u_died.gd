extends Control
func _ready() -> void:

	MusicMan.music(preload("res://assets/music/Daisy Chains (Lose Theme) Final.ogg"))

func _on_button_pressed() -> void:
	SceneGirl.change_scene("res://scenes/main_menu/main_menu.tscn") 
