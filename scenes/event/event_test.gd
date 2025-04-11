extends Control

const EVENT = preload("res://scenes/event/event.tscn")

func _ready() -> void:
	SceneGirl.push_scene.call_deferred(EVENT, func (e):
		pass)
