extends TileMap

var terrain = []
var bounds

var mstar
var unitRadar = []

var heightmap = []

func _process(delta):
	pass

func get_actors():
	var a = []
	
	for i in get_children():
		if i.is_in_group("Actors"):
			a.append(i)
	
	return a

func _ready():
	set_process(true)
	bounds = get_used_rect()
	
	#mstar.resize(bounds.size.x * bounds.size.y)
	terrain.resize(bounds.size.x * bounds.size.y)
	heightmap.resize(bounds.size.x * bounds.size.y)
	unitRadar.resize(bounds.size.x * bounds.size.y)
	
	mstar = preload("res://Data/Scripts/MStar.gd").new(24, 24)
	
	for x in range(bounds.pos.x, bounds.pos.x + bounds.size.x):
		for y in range(bounds.pos.y, bounds.pos.y + bounds.size.y):
			var p = Vector2(x, y)
			set_terrainv(p, get_cellv(p) >= 0)
			
			set_unit_at(p, null)
			
			if get_cellv(p) >= 0:
				set_heightv(p, get_tileset().tile_get_occluder_offset(get_cellv(p)).y)
			else:
				forbid_at(x, y)
	pass
	
	
	block_based_on_tilemap(get_node("Collider"))

func block_based_on_tilemap(tilemap):
	for x in range(bounds.pos.x, bounds.pos.x + bounds.size.x):
		for y in range(bounds.pos.x, bounds.pos.y + bounds.size.y):
			if tilemap.get_cell(x, y) >= 0:
				forbid_at(x, y)

func get_half_cell_size():
	return get_cell_size() / 2

func find_path(from, to):
	var f = mtbv(from)
	var t = mtbv(to)
	
	#var w =  mstar.find_path_v(f, t)
	
	var pth = []
	
	for i in mstar.find_path_v(f, t):
		pth.append(btmv(i))
	
	return pth

func forbid_at(x, y):
	var _p = mtb(x, y)
	#var _y = mtb(y)
	
	return mstar.forbid(_p.x, _p.y)

func free_at(x, y):
	var _p = mtb(x, y)
	return mstar.freec(_p.x, _p.y)


func set_unit_at(vec, value):
	
	var boundedPos = map_to_bounds_v(vec)
	var pos = flatten(boundedPos.x, boundedPos.y)
	
	unitRadar[pos] = value

func get_unit_at(vec):
	
	var boundedPos = map_to_bounds_v(vec)
	var pos = flatten(boundedPos.x, boundedPos.y)
	
	return unitRadar[pos]


#func block_at(x, y):
	#mstar.

func set_terrainv(vec, value):
	
	var boundedPos = map_to_bounds_v(vec)
	var pos = flatten(boundedPos.x, boundedPos.y)
	
	terrain[pos] = value

func get_terrainv(vec):
	
	var boundedPos = map_to_bounds_v(vec)
	var pos = flatten(boundedPos.x, boundedPos.y)
	
	return terrain[pos]

func set_heightv(vec, value):
	
	var boundedPos = map_to_bounds_v(vec)
	var pos = flatten(boundedPos.x, boundedPos.y)
	
	heightmap[pos] = value

func get_heightv(vec):
	
	var boundedPos = map_to_bounds_v(vec)
	var pos = flatten(boundedPos.x, boundedPos.y)
	
	return heightmap[pos] 


func flatten(x, y):
	return x + y * bounds.size.x

func flattenv(vec):
	return vec.x + vec.y * bounds.size.x

func map_to_bounds_v(vec):
	return Vector2(vec.x - bounds.pos.x, vec.y - bounds.pos.y)


func mtb(x, y):
	return Vector2(x - bounds.pos.x, y - bounds.pos.y)

func mtbv(vec):
	return Vector2(vec.x - bounds.pos.x, vec.y - bounds.pos.y)

func btmv(vec):
	return Vector2(vec.x + bounds.pos.x, vec.y + bounds.pos.y)



func get_tile_height(x, y):
	return heightmap[flattenv(mtb(x, y))]
	
	
	
	
	
	