extends CanvasLayer

const MUSIC_OFF = preload("res://assets/textures/music_off.png")
const MUSIC_ON = preload("res://assets/textures/music_on.png")

@onready var music_button: Button = $MusicButton
@onready var music_bus: int = AudioServer.get_bus_index("Music")

func _ready() -> void:
	music_button.icon = MUSIC_OFF if AudioServer.is_bus_mute(music_bus) else MUSIC_ON

func _on_music_button_pressed() -> void:
	AudioServer.set_bus_mute(music_bus, not AudioServer.is_bus_mute(music_bus))
	music_button.icon = MUSIC_OFF if AudioServer.is_bus_mute(music_bus) else MUSIC_ON
