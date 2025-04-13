@tool
class_name RemoteCanvasLayer
extends CanvasLayer

@export var viewport_path: NodePath = "/root/SceneRoot/AspectRatioContainer/HighRes/HighResSubViewport"

func _ready() -> void:
	(func ():
		if has_node(viewport_path):
			custom_viewport = get_node(viewport_path)
		else:
			push_warning("viewport_path not found: ", viewport_path)
	).call_deferred()
