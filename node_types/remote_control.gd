@tool
class_name RemoteControl
extends Control

## Path to the target node to be remote-controlled.
@export var remote_node: Control:
	set(v):
		if remote_node == v:
			return
		remote_node = v
		if is_inside_tree():
			_update_remote()
		update_configuration_warnings()

## If true, global coordinates are used. If false, local coordinates are used.
@export var use_global_coordinates: bool = true:
	set(enable):
		if use_global_coordinates == enable:
			return
		use_global_coordinates = enable
		set_notify_transform(use_global_coordinates)
		set_notify_local_transform(not use_global_coordinates)
		_update_remote()
	get:
		return use_global_coordinates

## If true, the remote node's position will be updated.
@export var update_position: bool = true:
	set(update):
		if update_remote_position == update:
			return
		update_remote_position = update
		_update_remote()
	get:
		return update_remote_position

## If true, the remote node's rotation will be updated.
@export var update_rotation: bool = true:
	set(update):
		if update_remote_rotation == update:
			return
		update_remote_rotation = update
		_update_remote()
	get:
		return update_remote_rotation

## If true, the remote node's scale will be updated.
@export var update_scale: bool = true:
	set(update):
		if update_remote_scale == update:
			return
		update_remote_scale = update
		_update_remote()
	get:
		return update_remote_scale

# Internal variables
var update_remote_position: bool = true
var update_remote_rotation: bool = true
var update_remote_scale: bool = true

func _ready() -> void:
	set_notify_transform(use_global_coordinates)
	set_notify_local_transform(not use_global_coordinates)

func _notification(what: int) -> void:
	match what:
		NOTIFICATION_RESET_PHYSICS_INTERPOLATION:
			_update_remote()
			if is_instance_valid(remote_node):
				remote_node.reset_physics_interpolation()
		
		NOTIFICATION_LOCAL_TRANSFORM_CHANGED, NOTIFICATION_TRANSFORM_CHANGED:
			if not is_inside_tree():
				return
			
			_update_remote()

func _get_minimum_size() -> Vector2:
	if is_instance_valid(remote_node):
		return remote_node.get_combined_minimum_size()
	return Vector2.ZERO

func _update_remote() -> void:
	if not is_inside_tree():
		return
	
	if not is_instance_valid(remote_node):
		return
	
	if not remote_node.is_inside_tree():
		return
	
	if not (update_remote_position or update_remote_rotation or update_remote_scale):
		return  # The transform data of the RemoteTransform2D is not used at all
	
	if use_global_coordinates:
		var n_trans = remote_node.get_global_transform_with_canvas()
		var our_trans = get_global_transform_with_canvas()
		
		# There are more steps in the operation of set_rotation, so avoid calling it
		var trans = our_trans if update_remote_rotation else n_trans
		
		if update_remote_rotation != update_remote_position:
			trans.origin = our_trans.origin if update_remote_position else n_trans.origin
		
		if update_remote_rotation != update_remote_scale:
			trans.scale = our_trans.scale if update_remote_scale else n_trans.scale
		
		remote_node.global_position = trans.origin
		remote_node.size = size
		remote_node.scale = trans.get_scale()
		remote_node.rotation = trans.get_rotation()
	else:
		var n_trans = remote_node.get_global_transform_with_canvas()
		var our_trans = get_global_transform_with_canvas()
		
		# There are more steps in the operation of set_rotation, so avoid calling it
		var trans = our_trans if update_remote_rotation else n_trans
		
		if update_remote_rotation != update_remote_position:
			trans.origin = our_trans.origin if update_remote_position else n_trans.origin
		
		if update_remote_rotation != update_remote_scale:
			trans.scale = our_trans.scale if update_remote_scale else n_trans.scale
		
		remote_node.position = trans.origin
		remote_node.size = size
		remote_node.scale = trans.get_scale()
		remote_node.rotation = trans.get_rotation()

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	
	if not is_instance_valid(remote_node):
		warnings.append("Path property must point to a valid Node2D node to work.")
	
	return warnings
