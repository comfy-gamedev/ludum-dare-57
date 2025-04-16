@tool
class_name SubViewportControl
extends Control

const SHADER = preload("res://addons/smooth_pixel_subviewport_container/smooth_pixel_subviewport_container.gdshader")

## Smooths camera motion. When disabled, the camera will snap to pixels.
@export var smoothcam_enabled: bool = true: set = enable_smoothcam

## Anti-aliases the edges of pixels.
@export var antialiasing_enabled: bool = true: set = enable_antialiasing

var _smooth_viewport_shader_material: ShaderMaterial

func _init() -> void:
	set_process_unhandled_input(true)
	focus_mode = FOCUS_CLICK

func _enter_tree() -> void:
	_update_visibility()
	if is_node_ready():
		_configure()

func _exit_tree() -> void:
	if RenderingServer.frame_pre_draw.is_connected(_on_rendering_server_frame_pre_draw):
		RenderingServer.frame_pre_draw.disconnect(_on_rendering_server_frame_pre_draw)

func _ready() -> void:
	visibility_changed.connect(_update_visibility)
	focus_entered.connect(_on_focus_entered)
	focus_exited.connect(_on_focus_exited)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	child_order_changed.connect(_on_child_order_changed)
	_smooth_viewport_shader_material = ShaderMaterial.new()
	_smooth_viewport_shader_material.shader = SHADER
	_configure()

func _process(delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	var c = get_first_subviewport()
	if not c:
		return
	
	draw_texture_rect(c.get_texture(), Rect2(Vector2(), get_size()), false)

func enable_smoothcam(v: bool) -> void:
	if smoothcam_enabled == v:
		return
	smoothcam_enabled = v
	if is_inside_tree():
		_configure()

func enable_antialiasing(v: bool) -> void:
	if antialiasing_enabled == v:
		return
	antialiasing_enabled = v
	if is_inside_tree():
		_configure()

func _configure() -> void:
	if smoothcam_enabled or antialiasing_enabled:
		material = _smooth_viewport_shader_material
	else:
		material = null
	
	if smoothcam_enabled:
		if not RenderingServer.frame_pre_draw.is_connected(_on_rendering_server_frame_pre_draw):
			RenderingServer.frame_pre_draw.connect(_on_rendering_server_frame_pre_draw)
	else:
		if RenderingServer.frame_pre_draw.is_connected(_on_rendering_server_frame_pre_draw):
			RenderingServer.frame_pre_draw.disconnect(_on_rendering_server_frame_pre_draw)
	
	if antialiasing_enabled:
		texture_filter = TEXTURE_FILTER_LINEAR
		texture_repeat = TEXTURE_REPEAT_DISABLED
	else:
		texture_filter = TEXTURE_FILTER_PARENT_NODE
		texture_repeat = TEXTURE_REPEAT_PARENT_NODE
	
	queue_redraw()

func _on_rendering_server_frame_pre_draw() -> void:
	var subviewport: SubViewport = null
	for c in get_children():
		if c is SubViewport:
			subviewport = c
			break
	if subviewport == null:
		return
	
	var camera_position := subviewport.canvas_transform.origin
	var rounded_position := camera_position.round()
	var offset := camera_position - rounded_position
	subviewport.canvas_transform.origin = rounded_position
	_smooth_viewport_shader_material.set_shader_parameter("vertex_offset", offset)

func _get_minimum_size() -> Vector2:
	return Vector2()

func get_allowed_size_flags_horizontal() -> PackedInt32Array:
	return PackedInt32Array()

func get_allowed_size_flags_vertical() -> PackedInt32Array:
	return PackedInt32Array()

func get_first_subviewport() -> SubViewport:
	for i in get_child_count():
		var c = get_child(i) as SubViewport
		if c:
			return c
	return null

func _update_visibility() -> void:
	var c = get_first_subviewport()
	if not c:
		return
	
	if is_visible_in_tree():
		c.set_update_mode(SubViewport.UPDATE_ALWAYS)
	else:
		c.set_update_mode(SubViewport.UPDATE_DISABLED)
	
	c.set_handle_input_locally(false)

func _on_focus_entered() -> void:
	set_process_input(true)
	set_process_unhandled_input(false)

func _on_focus_exited() -> void:
	set_process_input(false)
	set_process_unhandled_input(true)

func _on_mouse_entered() -> void:
	get_first_subviewport().notify_mouse_entered()

func _on_mouse_exited() -> void:
	get_first_subviewport().notify_mouse_exited()

func _input(p_event: InputEvent) -> void:
	_propagate_nonpositional_event(p_event)

func _unhandled_input(p_event: InputEvent) -> void:
	_propagate_nonpositional_event(p_event)

func _propagate_nonpositional_event(p_event: InputEvent) -> void:
	if p_event == null:
		push_error("InputEvent is null")
		return
	
	if Engine.is_editor_hint():
		return
	
	if _is_propagated_in_gui_input(p_event):
		return
	
	_send_event_to_viewports(p_event)

func _gui_input(p_event: InputEvent) -> void:
	if p_event == null:
		push_error("InputEvent is null")
		return
	
	if Engine.is_editor_hint():
		return
	
	if not _is_propagated_in_gui_input(p_event):
		return
	
	_send_event_to_viewports(p_event)

func _send_event_to_viewports(p_event: InputEvent) -> void:
	var c = get_first_subviewport()
	if not c or c.is_input_disabled():
		return
	
	var xform = Transform2D()
	xform = xform.scaled(Vector2(c.size) / size)
	p_event = p_event.xformed_by(xform)
	c.push_input(p_event)

func _is_propagated_in_gui_input(p_event: InputEvent) -> bool:
	# Propagation of events with a position property happen in gui_input.
	# Propagation of other events happen in input.
	return (p_event is InputEventMouse or 
		   p_event is InputEventScreenDrag or 
		   p_event is InputEventScreenTouch or 
		   p_event is InputEventGesture)

func _on_child_order_changed() -> void:
	queue_redraw()

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray
	
	var viewport_count = 0
	for i in get_child_count():
		if get_child(i) is SubViewport:
			viewport_count += 1
	
	if viewport_count == 0:
		warnings.push_back("This node doesn't have a SubViewport as child, so it can't display its intended content.\nConsider adding a SubViewport as a child to provide something displayable.")
	if viewport_count > 1:
		warnings.push_back("This node only allows a single SubViewport child.")
	
	if get_default_cursor_shape() != Control.CURSOR_ARROW:
		warnings.push_back("The default mouse cursor shape of SubViewportContainer has no effect.\nConsider leaving it at its initial value `CURSOR_ARROW`.")
	
	return warnings
