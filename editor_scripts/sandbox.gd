@tool
extends EditorScript


func _run() -> void:
	for f in DirAccess.get_files_at("res://assets/items/"):
		var i = load("res://assets/items/".path_join(f))
		i.count = maxi(0, int(i.count))
		ResourceSaver.save(i)
