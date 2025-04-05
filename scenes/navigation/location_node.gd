extends TextureButton

var type := Globals.LOCATION_TYPES.ENEMY

var next_nodes : Array[Node] = []


func _on_pressed() -> void:
	SceneGirl.change_scene("res://scenes/main_gameplay/main_gameplay.tscn")
