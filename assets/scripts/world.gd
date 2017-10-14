extends Node

var width
var height

var mstar

#this is used to keep track of where units are
var units = []

#this checks where there's an actual place and where there isn't
var terrain

#this is used to keep track of tiles heights
var heightmap = []

export(int) var pixelsPerHeight

func _ready():
	
	#get arena size to determine the size of the astar map
	var arenaSize = get_node("arena").get_used_rect().size
	width  = arenaSize.x - 1
	height = arenaSize.y - 1
	
	print("Arena size: ", width, "x", height)
	
	heightmap.resize(width * height)
	units.resize(width * height)
	
	mstar = preload("res://assets/scripts/mstar.gd").new(width, height)
	#terrain = get_node("terrain")
	
	var tileset = get_tileset()
	
	for x in range(0, width - 1):
		for y in range(0, height - 1):
			var p = Vector2(x, y)
			var id = flv(p)
			
			units[id] = null
			
			if get_cellv(p) >= 0:
				var h = tileset.tile_get_occluder_offset(get_cellv(p)).y
				heightmap[id] = h
			else:
				forbid_at(x, y)
				heightmap[id] = 0

func set_unit_at(pos, unit):
	units[flv(pos)] = unit

func forbid_at(x, y):
	mstar.forbid(x, y)

func free_at(x, y):
	mstar.freec(x, y)

func get_heightmap_at_v(vec):
	return heightmap[flv(vec)]

#this returns an 1D index of the 2D position
func flv(vec):
	return mstar.flatten(vec.x, vec.y)

func is_withinv(vec):
	return (vec.x >= 0 && vec.y >= 0 && vec.x < width && vec.y < height)

