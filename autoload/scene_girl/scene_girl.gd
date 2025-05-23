extends Node
## A scene changer which also handles transitions and loading screens.
##
## Default transitions and a loading screen are provided.
## It is expected that these will be modified on a per-project basis.
##
## Transitions can also be overridden by each scene (see [method change_scene]).
##
## [member minimum_load_time] is used to force the loading screen to be show.
## It will automatically be set to 0.0 in exported builds.

## Emitted each frame to indicate loading progress ([param value] ranges from 0.0 to 1.0).
signal load_progress(value: float)

## Minimum time to show the loading screen for.
## [signal load_progress] will be simulated with fake values.
## Automatically set to 0.0 when running in an exported build.
var minimum_load_time: float = 0.0

var default_transition_scene: PackedScene = preload("res://autoload/scene_girl/default_scene_transition.tscn")
var default_loading_screen_scene: PackedScene = preload("res://autoload/scene_girl/default_loading_screen.tscn")

@onready var scene_root: Node = get_tree().root
@onready var transition_root: Node = scene_root
@onready var current_scene: Node = get_tree().current_scene

var _default_transition: AnimationPlayer = null
var _current_transition: AnimationPlayer = null
var _pending_change_scene_file: String = ""
var _pending_change_unload_current: bool = true
var _loading_screen: Node = null
var _time_elapsed: float = 0.0

func _ready() -> void:
	if OS.has_feature("template"):
		minimum_load_time = 0.0
	process_mode = Node.PROCESS_MODE_ALWAYS
	set_process(false)

func _process(delta: float) -> void:
	if _pending_change_scene_file == "":
		push_error("Scene load seemingly aborted early.")
		set_process(false)
		return
	
	var progress = []
	var status := ResourceLoader.load_threaded_get_status(_pending_change_scene_file, progress)
	
	# Fake load time
	_time_elapsed += delta
	if _time_elapsed < minimum_load_time:
		match status:
			ResourceLoader.THREAD_LOAD_IN_PROGRESS:
				progress[0] = min(progress[0], _time_elapsed / minimum_load_time)
			ResourceLoader.THREAD_LOAD_LOADED:
				progress[0] = _time_elapsed / minimum_load_time
				status = ResourceLoader.THREAD_LOAD_IN_PROGRESS
	
	match status:
		ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
			push_error("Scene resource invalid.")
			_finish_change_scene(null)
		ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			load_progress.emit(progress[0])
		ResourceLoader.THREAD_LOAD_FAILED:
			push_error("Scene loading failed.")
			_finish_change_scene(null)
		ResourceLoader.THREAD_LOAD_LOADED:
			var next_scene = ResourceLoader.load_threaded_get(_pending_change_scene_file)
			_finish_change_scene(next_scene.instantiate())

func set_scene_root(node: Node) -> void:
	scene_root = node

func set_transition_root(node: Node) -> void:
	transition_root = node

## Initiates a scene change.
##
## Immediately pauses the scene and begins loading [param scene_file] in the background.
##
## First, the out transition will be played.
## If the current scene has a node named "SceneTransition",
## that node's "out" animation will be played.
## Otherwise, [member default_transition_scene] is instantiated and its "out" animation is played.
##
## Then, the loading screen will be instantiated.
## Note that the current scene is still loaded.
##
## When the [param scene_file] is done loading, the loading screen is freed,
## and the scene is changed to the newly loaded scene.
##
## The "in" transition animation will be played using the same logic as the "out" animation.
##
## [param scene_file]: the file path to the PackedScene to be loaded.
## [param unload_current]: determines whether the current scene will be unloaded.
func change_scene(scene_file: String, unload_current: bool = true) -> void:
	if _pending_change_scene_file:
		push_error("Cannot change scene while another is pending.")
		return
	
	_pending_change_scene_file = scene_file
	_pending_change_unload_current = unload_current
	
	_current_transition = current_scene.get_node_or_null("SceneTransition")
	
	if not _current_transition:
		_default_transition = default_transition_scene.instantiate()
		transition_root.add_child(_default_transition)
		_current_transition = _default_transition
	
	_current_transition.play("out")
	_current_transition.animation_finished.connect(_on_out_animation_finished)
	_current_transition.process_mode = Node.PROCESS_MODE_ALWAYS
	
	ResourceLoader.load_threaded_request(_pending_change_scene_file)
	
	get_tree().paused = true

var scene_stack: Array[Node] = []

func push_scene(scene: PackedScene, setup: Callable = Callable()) -> void:
	if _pending_change_scene_file:
		push_error("Cannot change scene while another is pending.")
		return
	
	scene_stack.push_back(current_scene)
	scene_root.remove_child(current_scene)
	var new_node = scene.instantiate()
	setup.call(new_node)
	scene_root.add_child(new_node)
	current_scene = new_node

func pop_scene() -> void:
	if _pending_change_scene_file:
		push_error("Cannot change scene while another is pending.")
		return
	
	var old_node = scene_stack.pop_back()
	current_scene.queue_free()
	scene_root.remove_child(current_scene)
	if old_node:
		scene_root.add_child(old_node)
		current_scene = old_node

func _on_out_animation_finished(anim_name: StringName) -> void:
	assert(anim_name == &"out")
	if anim_name != &"out":
		return
	
	if _current_transition:
		_current_transition.animation_finished.disconnect(_on_out_animation_finished)
	
	_current_transition = null
	_time_elapsed = 0.0
	set_process(true)
	
	if default_loading_screen_scene:
		_loading_screen = default_loading_screen_scene.instantiate()
		transition_root.add_child(_loading_screen)

func _finish_change_scene(next_scene: Node) -> void:
	if _pending_change_unload_current:
		current_scene.queue_free()
		current_scene = null
	
	_pending_change_scene_file = ""
	set_process(false)
	
	if _loading_screen:
		_loading_screen.queue_free()
		_loading_screen = null
	
	_add_current_scene.call_deferred(next_scene)

func _add_current_scene(next_scene: Node) -> void:
	if not next_scene:
		current_scene = null
		return
	
	scene_root.add_child(next_scene)
	current_scene = next_scene
	
	_current_transition = current_scene.get_node_or_null("SceneTransition")
	
	if not _current_transition:
		if not _default_transition:
			_default_transition = default_transition_scene.instantiate()
			transition_root.add_child(_default_transition)
		_current_transition = _default_transition
	else:
		if _default_transition:
			_default_transition.queue_free()
			_default_transition = null
	
	_current_transition.play("in")
	_current_transition.animation_finished.connect(_on_in_animation_finished)
	_current_transition.process_mode = Node.PROCESS_MODE_ALWAYS

func _on_in_animation_finished(anim_name: StringName) -> void:
	assert(anim_name == &"in")
	if anim_name != &"in":
		return
	
	if _default_transition:
		_default_transition.queue_free()
		_default_transition = null
	
	if _current_transition:
		_current_transition.animation_finished.disconnect(_on_in_animation_finished)
	
	_current_transition = null
	get_tree().paused = false
