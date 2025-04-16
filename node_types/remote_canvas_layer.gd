class_name RemoteCanvasLayer
extends CanvasLayer

@export var viewport_path: NodePath = ""

func _ready() -> void:
	if not viewport_path:
		viewport_path = "/root/SceneRoot/AspectRatioContainer/HighRes/HighResSubViewport"
	(func ():
		if has_node(viewport_path):
			custom_viewport = get_node(viewport_path)
		else:
			push_warning("viewport_path not found: ", viewport_path)
	).call_deferred()
