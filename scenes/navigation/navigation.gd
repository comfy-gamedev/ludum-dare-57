extends Control

const LAYERS = 15
const WIDTH = 7
const PATHS = 6
const CENTER = WIDTH - 1

const BATTLE = preload("res://scenes/battle/battle.tscn")
const EVENT = preload("res://scenes/event/event.tscn")
const ROTA_PIPE = preload("res://actors/rota_pipe.tscn")

const TILESET_SOURCE_PIPES = 0
const TILESET_SOURCE_LOCATIONS = 1

const CELL_NEIGHBORS = [
	TileSet.CELL_NEIGHBOR_TOP_SIDE,
	TileSet.CELL_NEIGHBOR_LEFT_SIDE,
	TileSet.CELL_NEIGHBOR_RIGHT_SIDE,
	TileSet.CELL_NEIGHBOR_BOTTOM_SIDE,
]

enum LocationType {
	ENEMY = 1,
	ELITE = 2,
	TREASURE = 0,
	EVENT = 3,
	EMPTY = 7,
	BOSS = 6,
	MUTATION = 4,
	SHOP = 5,
}

enum LocationState {
	AVAILABLE,
	VISITED,
	CURRENT,
}

enum LocationTileY {
	VISITED = 0,
	CURRENT = 1,
	HIGHLIGHT = 2,
	DISABLED = 3,
}



@onready var tilemap: TileMapLayer = %TileMapLayer
@onready var scroll_container: ScrollContainer = %ScrollContainer

var current_node: Vector2i

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

var rooms: Dictionary[Vector2i, RoomInfo] = {}
var rotapipes: Dictionary[Vector2i, RotaPipe]
var peering_table: Dictionary[int, Vector2i] = {}

func _ready() -> void:
	var tile_source: TileSetAtlasSource = tilemap.tile_set.get_source(TILESET_SOURCE_PIPES)
	for i in tile_source.get_tiles_count():
		var t = tile_source.get_tile_id(i)
		var td = tile_source.get_tile_data(t, 0)
		if td.terrain != 0:
			continue
		var peering: int = 0
		for pb in CELL_NEIGHBORS:
			if td.get_terrain_peering_bit(pb) == 0:
				peering |= 1 << pb
		peering_table[peering] = t
	
	_reset()
	
	MusicMan.music(preload("res://assets/music/Pipe World (Adventure Theme) Final.ogg"))

func _enter_tree() -> void:
	if not is_node_ready():
		return
	MusicMan.music(preload("res://assets/music/Pipe World (Adventure Theme) Final.ogg"))
	match Globals.player_nav_event:
		"battle_won":
			match rooms[current_node].location:
				LocationType.ENEMY:
					SceneGirl.push_scene.call_deferred(preload("res://scenes/upgrade/upgrade.tscn"), func (s):
						s.reason = Enums.UPGRADE_REASON.ENEMY)
				LocationType.ELITE:
					SceneGirl.push_scene.call_deferred(preload("res://scenes/upgrade/upgrade.tscn"), func (s):
						s.reason = Enums.UPGRADE_REASON.ELITE)
				LocationType.BOSS:
					SceneGirl.push_scene.call_deferred(preload("res://scenes/upgrade/upgrade.tscn"), func (s):
						s.reason = Enums.UPGRADE_REASON.BOSS)
		"battle_lost":
			SceneGirl.change_scene.call_deferred("res://scenes/you_died_lol/u_died.tscn")
		"forward":
			forward_two()
		"back":
			back_two()
	Globals.player_nav_event = ""
	
	if rooms[current_node].location == LocationType.BOSS:
		new_act()

func _reconcile(scroll_to_current: bool = true) -> void:
	for v in rooms:
		var r = rooms[v]
		if v in rooms[current_node].nexts:
			tilemap.set_cell(v, 1, Vector2i(r.location, LocationTileY.HIGHLIGHT), 0)
		else: match r.state:
			LocationState.AVAILABLE:
				tilemap.set_cell(v, 1, Vector2i(r.location, LocationTileY.DISABLED), 0)
			LocationState.VISITED:
				tilemap.set_cell(v, 1, Vector2i(r.location, LocationTileY.VISITED), 0)
			LocationState.CURRENT:
				tilemap.set_cell(v, 1, Vector2i(r.location, LocationTileY.CURRENT), 0)
	if scroll_to_current:
		scroll_container.set_deferred("scroll_vertical",
			tilemap.scale.y * tilemap.map_to_local(current_node + Vector2i(0, 1)).y - scroll_container.size.y / 2.0)

func back_two() -> void:
	_reconcile()

func forward_two() -> void:
	_reconcile()

func new_act() -> void:
	Globals.act += 1
	if Globals.act == 3:
		SceneGirl.change_scene("res://scenes/you_win/u_win.tscn")
	else:
		_reset()

func _reset() -> void:
	rooms.clear()
	tilemap.clear()
	
	var first_room = Vector2i(CENTER, 0)
	rooms[first_room] = RoomInfo.new()
	rooms[first_room].state = LocationState.CURRENT
	
	current_node = first_room
	
	for p in PATHS:
		var cur = first_room
		for l in LAYERS:
			var options = []
			for o in [cur.x - 2, cur.x, cur.x + 2]:
				var x = maxi(0, CENTER - 2 * (LAYERS - l - 1))
				if o < x:
					continue
				if o > WIDTH * 2 - x - 2:
					continue
				options.append(o)
			var next = Vector2i(options.pick_random(), 2 + l * 2) if l < LAYERS - 1 \
				else Vector2i(CENTER, 2 + l * 2)
			if next not in rooms:
				rooms[next] = RoomInfo.new()
			
			rooms[cur].nexts.insert(rooms[cur].nexts.bsearch(next, false), next)
			rooms[next].prevs.insert(rooms[next].nexts.bsearch(cur, false), cur)
			
			assert(next.x >= 0 and next.x <= WIDTH * 2 - 2)
			
			var start := mini(cur.x, next.x)
			var end := maxi(cur.x, next.x)
			for i in range(start, end + 1):
				var ii = Vector2i(i, cur.y + 1)
				var peering: int = 0
				var td = tilemap.get_cell_tile_data(ii)
				if td:
					for c in CELL_NEIGHBORS:
						if td.get_terrain_peering_bit(c) == 0:
							peering |= 1 << c
				if i == cur.x:
					peering |= 1 << TileSet.CELL_NEIGHBOR_TOP_SIDE
				if i == next.x:
					peering |= 1 << TileSet.CELL_NEIGHBOR_BOTTOM_SIDE
				if i != end:
					peering |= 1 << TileSet.CELL_NEIGHBOR_RIGHT_SIDE
				if i != start:
					peering |= 1 << TileSet.CELL_NEIGHBOR_LEFT_SIDE
				tilemap.set_cell(ii, TILESET_SOURCE_PIPES, peering_table[peering], 0)
			cur = next
	
	var random_rooms = []
	
	for v: Vector2i in rooms:
		var room = rooms[v]
		if v == first_room:
			room.location = LocationType.EMPTY
		elif v.y == LAYERS * 2:
			room.location = LocationType.BOSS
		elif v.y == LAYERS * 2 - 2:
			room.location = LocationType.TREASURE
		elif v.y == floori(LAYERS / 2.0) * 2:
			room.location = LocationType.MUTATION
		else:
			random_rooms.append(v)
	
	var bag = []
	bag.resize(random_rooms.size())
	for i in bag.size():
		var r = float(i) / float(bag.size() - 1)
		if r < 0.05:
			bag[i] = LocationType.SHOP
		elif r < 0.15:
			bag[i] = LocationType.ELITE
		elif r < 0.3:
			bag[i] = LocationType.MUTATION
		elif r < 0.55:
			bag[i] = LocationType.EVENT
		else:
			bag[i] = LocationType.ENEMY
	bag.shuffle()
	
	for i in random_rooms.size():
		rooms[random_rooms[i]].location = bag[i]
	
	for v in rooms:
		tilemap.set_cell(v, TILESET_SOURCE_LOCATIONS, Vector2i(rooms[v].location, 0), 0)
	
	tilemap.get_parent().custom_minimum_size.y = tilemap.map_to_local(tilemap.get_used_rect().end).y * 2
	
	for join_row in [floori(LAYERS / 3.0) * 2, floori(LAYERS * 2.0 / 3.0) * 2]:
		var row_pipes = []
		var cur_pipe := {} # { span, rooms }
		
		for i in WIDTH:
			var v = Vector2i(i * 2, join_row)
			if v not in rooms:
				continue
			
			if not cur_pipe:
				cur_pipe = { span = [v.x, v.x + 1], rooms = [] as Array[Vector2i] }
			
			var pipe_section = [v.x, v.x + 1]
			for n in rooms[v].nexts:
				if n.x < pipe_section[0]:
					pipe_section[0] = n.x
				if n.x >= pipe_section[1]:
					pipe_section[1] = n.x + 1
			
			if pipe_section[0] <= cur_pipe.span[1] and pipe_section[1] >= cur_pipe.span[0]:
				cur_pipe.span[0] = mini(cur_pipe.span[0], pipe_section[0])
				cur_pipe.span[1] = maxi(cur_pipe.span[1], pipe_section[1])
				cur_pipe.rooms.append(v)
			else:
				row_pipes.append(cur_pipe)
				cur_pipe = { span = pipe_section, rooms = [v] as Array[Vector2i] }
		
		row_pipes.append(cur_pipe)
		
		if row_pipes.size() > 1:
			var i = floori(row_pipes.size() / 2.0) - 1
			var start: int = row_pipes[i].span[1] - 1
			var end: int = row_pipes[i + 1].span[0]
			for x in range(start, end + 1):
				var v = Vector2i(x, join_row + 1)
				if x == floori((start + end) / 2.0):
					var rota: RotaPipe = ROTA_PIPE.instantiate()
					rota.prevs = row_pipes[i].rooms + row_pipes[i + 1].rooms
					rota.position = tilemap.map_to_local(v)
					tilemap.add_child(rota)
					rotapipes[v] = rota
					continue
				var peering: int = 0
				var td = tilemap.get_cell_tile_data(v)
				if td:
					for c in CELL_NEIGHBORS:
						if td.get_terrain_peering_bit(c) == 0:
							peering |= 1 << c
					if x != end:
						peering |= 1 << TileSet.CELL_NEIGHBOR_RIGHT_SIDE
					if x != start:
						peering |= 1 << TileSet.CELL_NEIGHBOR_LEFT_SIDE
				else:
					peering |= 1 << TileSet.CELL_NEIGHBOR_LEFT_SIDE
					peering |= 1 << TileSet.CELL_NEIGHBOR_RIGHT_SIDE
				tilemap.set_cell(v, TILESET_SOURCE_PIPES, peering_table[peering], 0)
	
	_reconcile()

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_KP_8:
			accept_event()
			_reset()
		if event.pressed and event.keycode == KEY_SPACE:
			accept_event()
			if tilemap.scale == Vector2(1, 1):
				tilemap.position.x = 64.0 * (960.0 / 64.0 - 13.0) / 2.0
				tilemap.scale = Vector2(2, 2)
			else:
				tilemap.scale = Vector2(1, 1)
				tilemap.position.x = 32.0 * (960.0 / 32.0 - 13.0) / 2.0

func _on_scroll_container_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if not event.pressed:
			return
		
		if OS.has_feature("debug") and event.button_index == MOUSE_BUTTON_RIGHT:
			accept_event()
			
			var tile_coord = tilemap.local_to_map(tilemap.get_local_mouse_position())
			if tile_coord in rooms:
				rooms[current_node].state = LocationState.VISITED
				current_node = tile_coord
				rooms[current_node].state = LocationState.CURRENT
				_reconcile()
				return
		
		if event.button_index != MOUSE_BUTTON_LEFT:
			return
		
		accept_event()
		
		var tile_coord = tilemap.local_to_map(tilemap.get_local_mouse_position())
		
		if tile_coord in rotapipes:
			var rp = rotapipes[tile_coord]
			if not rp.is_fixed:
				rp.fix()
				var new_nexts: Array[Vector2i]
				for p in rp.prevs:
					for v in rooms[p].nexts:
						var i = new_nexts.bsearch(v)
						if i == new_nexts.size() or new_nexts[i] != v:
							new_nexts.insert(i, v)
				for p in rp.prevs:
					rooms[p].nexts = new_nexts
				_reconcile(false)
		
		if tile_coord not in rooms[current_node].nexts:
			return
		
		rooms[current_node].state = LocationState.VISITED
		current_node = tile_coord
		
		if rooms[current_node].state == LocationState.AVAILABLE:
			_activate_current_room.call_deferred()
		
		rooms[current_node].state = LocationState.CURRENT
		
		_reconcile()

func _activate_current_room() -> void:
	match rooms[current_node].location:
		LocationType.ENEMY:
			SceneGirl.push_scene(BATTLE, func (battle):
				battle.state.enemy = load(enemies.pick_random()))
		LocationType.ELITE:
			SceneGirl.push_scene(BATTLE, func (battle):
				battle.state.enemy = load(elites.pick_random()))
		LocationType.BOSS:
			SceneGirl.push_scene(BATTLE, func (battle):
				battle.state.enemy = load(bosses.pick_random()))
		LocationType.EVENT:
			SceneGirl.push_scene(EVENT, func(x):)
		LocationType.TREASURE:
			SceneGirl.push_scene(preload("res://scenes/upgrade/upgrade.tscn"), func (s):
				s.reason = Enums.UPGRADE_REASON.TREASURE)
		LocationType.MUTATION:
			SceneGirl.push_scene(preload("res://scenes/upgrade/upgrade.tscn"), func (s):
				s.reason = Enums.UPGRADE_REASON.MUTATION)
		LocationType.SHOP:
			SceneGirl.push_scene(preload("res://scenes/shop/shop.tscn"), func (s):
				pass)

class RoomInfo:
	var location: LocationType = LocationType.EMPTY
	var state: LocationState = LocationState.AVAILABLE
	var prevs: Array[Vector2i] = []
	var nexts: Array[Vector2i] = []


