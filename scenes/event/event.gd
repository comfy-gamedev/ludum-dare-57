class_name EventScene
extends Control

signal choice(which: int)

const EVENT_OPTION = preload("res://scenes/event/event_option.tscn")

static var event_scripts: Array[String]

static func _static_init() -> void:
	for f in DirAccess.get_files_at("res://scenes/event/event_scripts"):
		f = f.trim_suffix(".remap")
		if f == "_template.gd" or not f.ends_with(".gd"):
			continue
		event_scripts.append("res://scenes/event/event_scripts".path_join(f))

var event: RefCounted

var _options: Array[Node]

@onready var v_box: VBoxContainer = %VBox
@onready var image: TextureRect = %Image
@onready var event_text: RichTextLabel = %EventText

func _ready() -> void:
	if not event:
		event = load(event_scripts.pick_random()).new()
	
	await event.run(self)
	
	SceneGirl.pop_scene()

func set_image(texture: Texture2D) -> void:
	image.texture = texture

func set_description(text: String) -> void:
	event_text.text = _process_multiline(text)

func add_option(text: String) -> void:
	var o = EVENT_OPTION.instantiate()
	o.text = _process_multiline(text)
	v_box.add_child(o)
	_options.append(o)
	var index := _options.size() - 1
	o.pressed.connect(func ():
		choice.emit(index))

func disable_option(index: int = -1) -> void:
	_options[index].disabled = true

func clear() -> void:
	event_text.text = ""
	for o in _options:
		o.queue_free()
	_options.clear()

func _process_multiline(text: String) -> String:
	return TextUtils.dedent(text)
