class_name SceneRoot
extends Node

static var current: SceneRoot

@onready var pixel_sub_viewport: SubViewport = %PixelSubViewport
@onready var high_res_sub_viewport: SubViewport = %HighResSubViewport

func _ready() -> void:
	current = self
	_on_high_res_sub_viewport_size_changed.call_deferred()
	var window = get_viewport() as Window
	window.content_scale_mode = Window.CONTENT_SCALE_MODE_DISABLED
	SceneGirl.set_scene_root(pixel_sub_viewport)
	SceneGirl.change_scene("res://scenes/main_menu/main_menu.tscn", false)

func _on_high_res_sub_viewport_size_changed() -> void:
	if not is_node_ready():
		return
	(func ():
		var ts = TextServerManager.get_primary_interface()
		var window = get_viewport() as Window
		var os = float(window.size.x) / float(pixel_sub_viewport.size_2d_override.x) * window.content_scale_factor
		ts.font_set_global_oversampling(os if not is_inf(os) else 1.0)
		get_tree().root.propagate_notification(Control.NOTIFICATION_THEME_CHANGED)
		var canvas_xform = high_res_sub_viewport.global_canvas_transform
		var scl = canvas_xform.affine_inverse().get_scale() * Vector2(high_res_sub_viewport.size) / Vector2(pixel_sub_viewport.size_2d_override)
		canvas_xform = canvas_xform.scaled(scl)
		high_res_sub_viewport.global_canvas_transform = canvas_xform
	).call_deferred()

