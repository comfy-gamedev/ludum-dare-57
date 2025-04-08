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

var enemies = [
	"res://assets/enemies/fish.tres",
	"res://assets/enemies/rat.tres",
	"res://assets/enemies/slug.tres",
	"res://assets/enemies/snake.tres",
	"res://assets/enemies/turtle.tres",
]

var elites = [
	"res://assets/enemies/slime.tres",
	"res://assets/enemies/koba.tres",
	"res://assets/enemies/croc.tres",
]

var bosses = [
	"res://assets/enemies/croc_boss.tres",
]

func _ready() -> void:
	if current_node == Vector2i(0, 0):
		for i in 20:
			if tilemap.get_cell_atlas_coords(Vector2(i, 0)).x == Enums.LOCATION_TYPES.EMPTY:
				current_node = Vector2(i, 0)
				break
	visited_nodes.append(current_node)
	_reconcile()
	MusicMan.music(preload("res://assets/music/Pipe World (Adventure Theme) Final.ogg"))

func _enter_tree() -> void:
	if not is_node_ready():
		return
	MusicMan.music(preload("res://assets/music/Pipe World (Adventure Theme) Final.ogg"))
	match Globals.player_nav_event:
		"battle_won":
			var dest = tilemap.get_cell_atlas_coords(current_node)
			match dest.x:
				Enums.LOCATION_TYPES.ENEMY:
					SceneGirl.push_scene.call_deferred(preload("res://scenes/upgrade/upgrade.tscn"), func (s):
						s.reason = Enums.UPGRADE_REASON.ENEMY)
				Enums.LOCATION_TYPES.ELITE:
					SceneGirl.push_scene.call_deferred(preload("res://scenes/upgrade/upgrade.tscn"), func (s):
						s.reason = Enums.UPGRADE_REASON.ELITE)
				Enums.LOCATION_TYPES.BOSS:
					SceneGirl.push_scene.call_deferred(preload("res://scenes/upgrade/upgrade.tscn"), func (s):
						s.reason = Enums.UPGRADE_REASON.BOSS)
		"battle_lost":
			SceneGirl.change_scene.call_deferred("res://scenes/you_died_lol/u_died.tscn")
		"forward":
			forward_two()
		"back":
			back_two()
	Globals.player_nav_event = ""
	
	if find_next_nodes(current_node).size() == 0:
		new_act()

func _reconcile() -> void:
	var next_nodes = find_next_nodes(current_node)
	for c in tilemap.get_used_cells_by_id(1):
		var t = tilemap.get_cell_atlas_coords(c)
		if c in visited_nodes:
			tilemap.set_cell(c, 1, Vector2i(t.x, 0))
		elif c in next_nodes:
			tilemap.set_cell(c, 1, Vector2i(t.x, 1))
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

func back_two() -> void:
	if visited_nodes.size() > 1:
		current_node = visited_nodes[-2]
		visited_nodes.pop_back()
		visited_nodes.pop_back()
	else:
		current_node = visited_nodes[-1]
		visited_nodes.pop_back()
	
	_reconcile()

func forward_two() -> void:
	var options = []
	var good_options = []
	for n in tilemap.get_used_cells_by_id(1):
		if n.y == current_node.y + 2:
			options.append(n)
			if n not in visited_nodes:
				good_options.append(n)
	if not good_options.is_empty():
		options = good_options
	
	if options != []:
		current_node = options.pick_random() 
		visited_nodes.append(current_node)
		
		_reconcile()

func new_act() -> void:
	Globals.act += 1
	if Globals.act == 3:
		SceneGirl.change_scene("res://scenes/you_win/u_win.tscn")
	else:
		for i in tilemap.get_used_cells_by_id(1):
			if tilemap.get_cell_atlas_coords(i).x < 6:
				tilemap.set_cell(i, 1, Vector2i(randi_range(0, 5), 1))
		visited_nodes = []
		
		current_node = Vector2i(0, 0)
		$ScrollContainer.scroll_vertical = 0
		_ready()

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
			Enums.LOCATION_STATE.AVAILABLE, Enums.LOCATION_STATE.HIGHLIGHT:
				tilemap.set_cell(current_node, 1, Vector2i(dest.x, 0))
				current_node = tile_coord
				visited_nodes.append(current_node)
				_reconcile()
				print("Navigated to: ", current_node, " (", var_to_str(dest), ")")
				match dest.x:
					Enums.LOCATION_TYPES.ENEMY:
						SceneGirl.push_scene(BATTLE, func (battle):
							battle.battle_state.enemy = load(enemies.pick_random()))
					Enums.LOCATION_TYPES.ELITE:
						SceneGirl.push_scene(BATTLE, func (battle):
							battle.battle_state.enemy = load(elites.pick_random()))
					Enums.LOCATION_TYPES.BOSS:
						SceneGirl.push_scene(BATTLE, func (battle):
							battle.battle_state.enemy = load(bosses.pick_random()))
					Enums.LOCATION_TYPES.EVENT:
						SceneGirl.push_scene(EVENT, func(x):)
					Enums.LOCATION_TYPES.TREASURE:
						SceneGirl.push_scene(preload("res://scenes/upgrade/upgrade.tscn"), func (s):
							s.reason = Enums.UPGRADE_REASON.TREASURE)
					Enums.LOCATION_TYPES.MUTATION:
						SceneGirl.push_scene(preload("res://scenes/upgrade/upgrade.tscn"), func (s):
							s.reason = Enums.UPGRADE_REASON.MUTATION)
					Enums.LOCATION_TYPES.SHOP:
						SceneGirl.push_scene(preload("res://scenes/shop/shop.tscn"), func (s):
							pass)
