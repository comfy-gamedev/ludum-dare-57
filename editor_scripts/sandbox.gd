@tool
extends EditorScript


func _run() -> void:
	for f in DirAccess.get_files_at("res://assets/items/"):
		var i = load("res://assets/items/".path_join(f))
		i.item_rarity = Enums.ITEM_RARITY.COMMON
		ResourceSaver.save(i)
