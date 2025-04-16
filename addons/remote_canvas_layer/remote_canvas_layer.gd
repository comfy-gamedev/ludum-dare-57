@tool
extends EditorPlugin

var plugin: Plugin

func _enter_tree() -> void:
	plugin = Plugin.new(get_undo_redo())
	add_context_menu_plugin(EditorContextMenuPlugin.CONTEXT_SLOT_SCENE_TREE, plugin)


func _exit_tree() -> void:
	remove_context_menu_plugin(plugin)
	plugin = null

class Plugin extends EditorContextMenuPlugin:
	var undo_redo: EditorUndoRedoManager
	
	func _init(p_undo_redo: EditorUndoRedoManager) -> void:
		undo_redo = p_undo_redo
	
	func _popup_menu(paths: PackedStringArray) -> void:
		add_context_menu_item("Send to RemoteCanvasLayer", _send)
	func p(a): printerr(a)
	func _send(nodes: Array[Node]) -> void:
		var root = EditorInterface.get_edited_scene_root()
		var remotes = root.find_children("*", "RemoteCanvasLayer", false, true)
		var rcl: RemoteCanvasLayer
		if remotes.size() == 0:
			undo_redo.create_action("Create RemoteCanvasLayer", UndoRedo.MERGE_DISABLE, root)
			rcl = RemoteCanvasLayer.new()
			rcl.name = "RemoteCanvasLayer"
			undo_redo.add_do_reference(rcl)
			undo_redo.add_do_method(root, "add_child", rcl, true)
			undo_redo.add_do_property(rcl, "owner", root)
			undo_redo.add_undo_method(root, "remove_child", rcl)
			undo_redo.commit_action()
		else:
			rcl = remotes[0]
		for node in nodes:
			if rcl.is_ancestor_of(node):
				continue
			var control = node as Control
			if not control:
				continue
			var rc = RemoteControl.new()
			rc.name = "Remote" + control.name
			rc.position = control.position
			rc.size = control.size
			rc.size_flags_horizontal = control.size_flags_horizontal
			rc.size_flags_vertical = control.size_flags_vertical
			rc.size_flags_stretch_ratio = control.size_flags_stretch_ratio
			rc.anchor_bottom = control.anchor_bottom
			rc.anchor_top = control.anchor_top
			rc.anchor_left = control.anchor_left
			rc.anchor_right = control.anchor_right
			rc.remote_node = control
			undo_redo.create_action("Send to RemoteCanvasLayer", UndoRedo.MERGE_ALL, root)
			undo_redo.add_do_reference(rc)
			undo_redo.add_do_method(control, "replace_by", rc)
			undo_redo.add_do_property(rc, "owner", root)
			undo_redo.add_do_method(rcl, "add_child", control, true)
			undo_redo.add_do_property(control, "owner", root)
			
			undo_redo.add_undo_method(rcl, "remove_child", control)
			undo_redo.add_undo_method(rc, "replace_by", control)
			undo_redo.add_undo_property(control, "owner", root)
			
			undo_redo.commit_action()
