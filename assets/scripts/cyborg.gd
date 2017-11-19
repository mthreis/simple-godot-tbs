tool
extends Node2D

#========================================= basic info
var health = 100

#export(String, "regular", "wounded") var anim = "regular" setget set_anim, get_anim
var anim
#========================================= stuff

var gridPos
var isWounded

#========================================= equipments
var weapon
var accessory

var sprite 
var stats 
var info 
var world
export(int, "Ally", "Enemy") var group = 0

func _ready():
	sprite = get_node("sprite")
	stats  = get_node("stats")
	info   = get_node("info")
	world  = get_parent()
	
	gridPos = world.world_to_map(get_pos())
	fix_sprites_offset()

#================================================================================== getters & setters

func set_anim(_anim):
	anim = _anim
	
	var sp = get_node("sprite")
	
	if sp != null:
		for i in sp.get_children():
			i.set_hidden(true)
		
		get_node("sprite/" + anim).set_hidden(false)

func get_anim():
	return anim

#=====================================================================================

func fix_sprites_offset():
	for i in get_node("sprite").get_children():
		i.set_offset(i.get_offset() + Vector2(0, world.get_cell_size().y / 2 -  1) )

#=====================================================================================

func get_movable_panels():
	for i in world.get_actors():
		if group != i.group:
			world.forbid_at(i.gridPos.x, i.gridPos.y)
	
	var left = max(0, gridPos.x - stats.move)
	var right = min(gridPos.x + stats.move + 1, world.width)
	
	var top = max(0, gridPos.y - stats.move)
	var bottom = min(gridPos.y + stats.move + 1, world.height)
	
	var m = []
	
	print("gridPos", gridPos, " ----- from ", left, " to ", right)
	
	for x in range(left, right):
		for y in range(top, bottom):
			
			var p = Vector2(x, y)
			
			if world.get_unit_at(p):
				continue
			
			if world.get_cellv(p) >= 0:
				var path = world.find_path(gridPos, p)
				if path.size() > 0 && path.size() <= stats.move:
					m.append(p)
	
	for i in world.get_actors():
		if group != i.group:
			world.free_at(i.gridPos.x, i.gridPos.y)
	
	return m

func get_targettable_panels():
	var attackRange = max(1, weapon.radius)
	
	var left = max(0, gridPos.x - attackRange)
	var right = min(gridPos.x + attackRange + 1, world.width)
	
	var top = max(0, gridPos.y - attackRange)
	var bottom = min(gridPos.y + attackRange + 1, world.height)
	
	var m = []
	
	print("gridPos", gridPos, " ----- from ", left, " to ", right)
	
	for x in range(left, right):
		for y in range(top, bottom):
			
			var p = Vector2(x, y)
			
			#it's me .-.
			if p == gridPos:
				continue
			
			if world.get_terrainv(p) >= 0:
				var path = world.find_path(gridPos, p)
				if path.size() > 0 && path.size() <= attackRange:
					m.append(p)
	
	return m

func teleport_to_v(_pos):
	gridPos = _pos
	set_pos(world.map_to_world(gridPos) + Vector2(0, 2))

	var height = world.get_heightmap_at_v(gridPos)
	get_node("sprite").set_pos(Vector2(0, -height))