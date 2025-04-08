extends Control

@onready var start_game_button: Button = %StartGameButton
@onready var how_to_play_button: Button = %HowToPlayButton
@onready var options_button: Button = %OptionsButton


func _ready() -> void:
	start_game_button.grab_focus()
	MusicMan.music(preload("res://assets/music/Dead Flowers (Main Theme) Final.ogg"))


func _on_start_game_button_pressed() -> void:
	SceneGirl.change_scene("res://scenes/intro_panel/intro_panel.tscn")


func _on_how_to_play_button_pressed() -> void:
	SceneGirl.change_scene("res://scenes/how_to_play/how_to_play.tscn")

func _on_options_button_pressed() -> void:
	SceneGirl.change_scene("res://scenes/options/options.tscn")


func _on_start_game_button_mouse_entered() -> void:
	start_game_button.grab_focus()


func _on_how_to_play_button_mouse_entered() -> void:
	how_to_play_button.grab_focus()


func _on_options_button_mouse_entered() -> void:
	options_button.grab_focus()
