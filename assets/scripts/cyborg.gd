extends Node2D

#========================================= basic info
export(String) var name #the name of the robot
export(int) var id #unique identifier

export(int, 1, 10) var resistance = 3
export(int, 1, 10) var strength = 3
export(int, 1, 10) var accuracy = 3
export(int, 1, 5) var move = 3
export(int, 1, 5) var jump = 3
export(int, 1, 5) var ram = 3

export(String, "forza", "stano", "jolto") var body
var badges = [] #badges grant improvements and special cards to the cyborg

var health = 100

var anim = "regular" setget set_anim, get_anim

#========================================= stuff

var sprite
var gridPos

#========================================= equipments
var weapon
var accessory

export(int, "ally", "enemy") var group = 0

onready var world = get_parent()

func _ready():
	fix_sprites_offset()

func set_anim(_anim):
	anim = get_node("sprite/" + _anim)
	
	for i in get_node("sprite").get_children():
		set_hidden(true)
	
	anim.set_hidden(false)

func get_anim():
	return anim

func fix_sprites_offset():
	for i in get_node("sprite").get_children():
		i.set_offset(i.get_offset() + Vector2(0, world.get_cell_size().y / 2 -  1) )
	
	

#=====================================================================================

func get_movable_panels():
	
	for i in world.get_actors():
		if group != i.group:
			world.forbid_at(i.gridPos.x, i.gridPos.y)
	
	var left = max(world.bounds.pos.x, gridPos.x - move)
	var right = min(gridPos.x + move + 1, world.bounds.pos.x + world.bounds.size.x)
	
	var top = max(world.bounds.pos.y, gridPos.y - move)
	var bottom = min(gridPos.y + move + 1, world.bounds.pos.y + world.bounds.size.y)
	
	var m = []
	
	print("gridPos", gridPos, " ----- from ", left, " to ", right)
	
	for x in range(left, right):
		for y in range(top, bottom):
			
			var p = Vector2(x, y)
			
			if world.get_unit_at(p):
				continue
			
			if world.get_terrainv(p) >= 0:
				var path = world.find_path(gridPos, p)
				if path.size() > 0 && path.size() <= move:
					m.append(p)
	
	
	for i in world.get_actors():
		if group != i.group:
			world.free_at(i.gridPos.x, i.gridPos.y)
	
	return m




func get_targettable_panels():
	var rHr = 0
	var lHr = 0
	var rn = 0
	
	var attackRange = max(1, weapon.radius)
	
	var left = max(world.bounds.pos.x, gridPos.x - attackRange)
	var right = min(gridPos.x + attackRange + 1, world.bounds.pos.x + world.bounds.size.x)
	
	var top = max(world.bounds.pos.y, gridPos.y - attackRange)
	var bottom = min(gridPos.y + attackRange + 1, world.bounds.pos.y + world.bounds.size.y)
	
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
	
	
	#for i in world.get_actors():
	#	if group != i.group:
	#		world.free_at(i.gridPos.x, i.gridPos.y)
	
	return m
	


func teleport_to_v(_pos):
	gridPos = _pos
	set_pos(world.map_to_world(gridPos) + Vector2(0, 1))

	var height = world.get_heightmap_at_v(gridPos)
	get_node("sprite").set_pos(Vector2(0, -height))