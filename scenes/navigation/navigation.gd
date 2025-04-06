extends Node2D

#const LAYERS := 10
#const MAX_WIDTH := 5
#
#const H_SPACING := 50
#const W_SPACING := 50


var button_type := preload("res://scenes/navigation/location_node.tscn")
@onready var container := $NodeContainer
@onready var tilemap := $TileMapLayer

var current_node:= Vector2i(0, 0)

func _ready() -> void:
	_enter_tree()

func _enter_tree() -> void:
	if !is_node_ready():
		return
	
	if current_node == Vector2i(0, 0):
		for i in 20:
			if tilemap.get_cell_source_id(Vector2(i, 0)) > -1:
				current_node = Vector2(i, 0)
				break
	
	#disable all nodes
	#mark current node as current
	#mark available nodes as enabled #get_next_nodes(current_node)
	pass

func get_next_nodes(coord: Vector2i) -> Array[Vector2i]:
	var current_pipe := coord + Vector2i(0, 1)
	var nodes : Array[Vector2i] = []
	var status = "left"
	#move left
	while status != "done":
		match tilemap.get_cell_atlas_coords(current_pipe).x:
			2:#straight down
				nodes.append(current_pipe + Vector2i(0, 1))
				status = "done"
			1, 8:#sideways pipe, T junction up
				if status == "left":
					current_pipe += Vector2i.LEFT
				else:
					current_pipe += Vector2i.RIGHT
			4:#right angle left
				current_pipe += Vector2i.LEFT
			6:#right angle right
				current_pipe += Vector2i.RIGHT
			3, 5, 9, 10:#right angles down, T junction sideways
				nodes.append(current_pipe + Vector2i(0, 1))
				if status == "left":
					status = "right"
					current_pipe = coord + Vector2i(1, 1)
				else:
					status = "done"
			7, 0:#T junction down, 4 cross
				nodes.append(current_pipe + Vector2i(0, 1))
				if status == "left":
					current_pipe += Vector2i.LEFT
				else:
					current_pipe += Vector2i.RIGHT
	
	return nodes

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton && event.is_pressed():
		var tile_coord = tilemap.local_to_map(tilemap.get_local_mouse_position())
		if tilemap.get_cell_source_id(tile_coord) == 3:
			#switch event scenes here
			SceneGirl.change_scene("res://scenes/main_gameplay/main_gameplay.tscn")
