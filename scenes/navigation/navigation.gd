extends Node2D

#const LAYERS := 10
#const MAX_WIDTH := 5
#
#const H_SPACING := 50
#const W_SPACING := 50

const BATTLE = preload("res://scenes/battle/battle.tscn")
const EVENT = preload("res://scenes/event/event.tscn")
var button_type := preload("res://scenes/navigation/location_node.tscn")
@onready var container := $NodeContainer
@onready var tilemap: TileMapLayer = $ScrollContainer/PanelContainer/TileMapLayer4

var current_node := Vector2i(0, 0)
var visited_nodes: Array[Vector2i]

func _ready() -> void:
	if current_node == Vector2i(0, 0):
		for i in 20:
			if tilemap.get_cell_atlas_coords(Vector2(i, 0)).x == Enums.LOCATION_TYPES.EMPTY:
				current_node = Vector2(i, 0)
				break
	visited_nodes.append(current_node)
	_reconcile()

func _reconcile() -> void:
	var next_nodes = find_next_nodes(current_node)
	for c in tilemap.get_used_cells_by_id(1):
		var t = tilemap.get_cell_atlas_coords(c)
		if c == current_node:
			tilemap.set_cell(c, 1, Vector2i(t.x, 1))
		elif c in next_nodes:
			tilemap.set_cell(c, 1, Vector2i(t.x, 2))
		elif c in visited_nodes:
			tilemap.set_cell(c, 1, Vector2i(t.x, 0))
		else:
			tilemap.set_cell(c, 1, Vector2i(t.x, 3))

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
		if tilemap.get_cell_source_id(tile_coord) != 1:
			return
		var dest = tilemap.get_cell_atlas_coords(tile_coord)
		match dest.y:
			Enums.LOCATION_STATE.CROSSED,\
			Enums.LOCATION_STATE.DISABLED:
				pass
			Enums.LOCATION_STATE.AVAILABLE,\
			Enums.LOCATION_STATE.HIGHLIGHT:
				tilemap.set_cell(current_node, 1, Vector2i(dest.x, 0))
				current_node = tile_coord
				visited_nodes.append(current_node)
				_reconcile()
				print("Navigated to: ", current_node, " (", var_to_str(dest), ")")
				match dest.x:
					Enums.LOCATION_TYPES.ENEMY:
						SceneGirl.push_scene(BATTLE, func (battle):
							battle.battle_state.enemy = load("res://assets/enemies/rat.tres"))
					Enums.LOCATION_TYPES.EVENT:
						SceneGirl.push_scene(EVENT, func(x):)
