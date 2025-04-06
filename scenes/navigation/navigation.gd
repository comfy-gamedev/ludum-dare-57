extends Node2D

#const LAYERS := 10
#const MAX_WIDTH := 5
#
#const H_SPACING := 50
#const W_SPACING := 50

const BATTLE = preload("res://scenes/battle/battle.tscn")
var button_type := preload("res://scenes/navigation/location_node.tscn")
@onready var container := $NodeContainer
@onready var tilemap: TileMapLayer = $ScrollContainer/PanelContainer/TileMapLayer4

var current_node:= Vector2i(0, 0)

var next_nodes: Array[Vector2i]

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
	
	next_nodes = find_next_nodes(current_node)

func find_next_nodes(coord: Vector2i) -> Array[Vector2i]:
	var current_pipe := coord + Vector2i(0, 1)
	var nodes : Array[Vector2i] = []
	var status = "left"
	var td: TileData = tilemap.get_cell_tile_data(current_pipe)
	
	# scan left
	while td:
		var pb = td.get_terrain_peering_bit(TileSet.CELL_NEIGHBOR_LEFT_SIDE)
		if pb == -1:
			break
		current_pipe += Vector2i.LEFT
		td = tilemap.get_cell_tile_data(current_pipe)
	if not td:
		push_error("No td found.")
		return []
	
	# scan right
	while td:
		var down = td.get_terrain_peering_bit(TileSet.CELL_NEIGHBOR_BOTTOM_SIDE)
		if down != -1:
			nodes.append(current_pipe + Vector2i.DOWN)
		var right = td.get_terrain_peering_bit(TileSet.CELL_NEIGHBOR_RIGHT_SIDE)
		if right == -1:
			break
		current_pipe += Vector2i.RIGHT
		td = tilemap.get_cell_tile_data(current_pipe)
	
	return nodes

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton && event.is_pressed():
		var tile_coord = tilemap.local_to_map(tilemap.get_local_mouse_position())
		if tile_coord in next_nodes:
			current_node = tile_coord
			next_nodes = find_next_nodes(current_node)
			var dest = tilemap.get_cell_tile_data(current_node).get_custom_data("Destination")
			print("Navigated to: ", current_node, " (", var_to_str(dest), ")")
			print("Next nodes: ", next_nodes)
			match dest:
				&"battle_easy":
					var battle = BATTLE.instantiate()
					battle.battle_state.enemy = load("res://assets/enemies/rat.tres")
					add_child(battle)

