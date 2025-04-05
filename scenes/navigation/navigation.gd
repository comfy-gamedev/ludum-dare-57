extends Node2D

#const LAYERS := 10
#const MAX_WIDTH := 5
#
#const H_SPACING := 50
#const W_SPACING := 50


var button_type := preload("res://scenes/navigation/location_node.tscn")
@onready var container := $NodeContainer
@onready var tilemap := $TileMapLayer

func _ready() -> void:
	get_next_nodes(Vector2i(4, 0))
	
	#var width
	#var last_nodes := []
	#var current_nodes := []
	#
	#for i in LAYERS:
		#width = randi_range(3, MAX_WIDTH)
		#for j in width:
			#var loc_button := button_type.instantiate()
			#loc_button.position = Vector2(480 - ((W_SPACING / 2) * (width - 1)) + (W_SPACING * (j - 1)), 50 + (H_SPACING * i))
			#container.add_child(loc_button)
			#current_nodes.append(loc_button)
			#for k in last_nodes:
				#k.next_nodes.append(loc_button)
		#last_nodes = current_nodes
	#
	#for i in container.get_children():
		#for j in i.next_nodes:
			#var line = Line2D.new()
			#line.add_point(i.position)
			#line.add_point(j.position)

func get_next_nodes(coord: Vector2i) -> Array[Vector2i]:
	var current_pipe := coord + Vector2i(0, 1)
	var nodes : Array[Vector2i] = []
	var status = "left"
	#move left
	while status != "done":
		match tilemap.get_cell_atlas_coords(current_pipe).x:
			0:#straight down
				nodes.append(current_pipe + Vector2i(0, 1))
				status = "done"
			1:
				if status == "left":
					current_pipe += Vector2i.LEFT
				else:
					current_pipe += Vector2i.RIGHT
			2:#right angle
				current_pipe += Vector2i.LEFT
			3:
				current_pipe += Vector2i.RIGHT
			4, 5:
				nodes.append(current_pipe + Vector2i(0, 1))
				if status == "left":
					status = "right"
					current_pipe = coord + Vector2i(1, 1)
				else:
					status = "done"
			6:#T junction up
				if status == "left":
					current_pipe += Vector2i.LEFT
				else:
					current_pipe += Vector2i.RIGHT
			7:
				nodes.append(current_pipe + Vector2i(0, 1))
				if status == "left":
					current_pipe += Vector2i.LEFT
				else:
					current_pipe += Vector2i.RIGHT
			8, 9:
				nodes.append(current_pipe + Vector2i(0, 1))
				if status == "left":
					status = "right"
					current_pipe = coord + Vector2i(1, 1)
				else:
					status = "done"
			10:#4 cross
				nodes.append(current_pipe + Vector2i(0, 1))
				if status == "left":
					current_pipe += Vector2i.LEFT
				else:
					current_pipe += Vector2i.RIGHT
		
	return nodes

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton && event.is_pressed():
		var tile_coord = tilemap.local_to_map(tilemap.get_local_mouse_position())
		if tilemap.get_cell_source_id(tile_coord) == 2:
			#switch event scenes here
			SceneGirl.change_scene("res://scenes/main_gameplay/main_gameplay.tscn")
