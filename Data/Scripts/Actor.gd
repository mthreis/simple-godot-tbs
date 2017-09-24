extends Sprite

onready var world = get_parent()
var offset
var gridPos
var path = []
var isMoving = false

const ALLY = 0
const ENEMY = 1

export(int) var attackRange = 1

export var group = ALLY

const TOP = 3
const BOTTOM = 1
const RIGHT = 2
const LEFT = 0
var sideToNext = -1 

func get_angle_dg(from, to):
	var angle = (to - from).angle()
	angle = rad2deg(angle)
	angle += 180
	return angle

func get_side(angle):
	return floor(angle / 90)
	


var height

export(int) var move = 2

var nextSpot
var nextHeight

func set_height(v):
	height = v
	set_offset(offset - Vector2(0, height))

func _process(delta):
	if isMoving:
		var motion = nextSpot - get_pos()
		var h = nextHeight - height
		
		if motion.length_squared() > 0.75:
			
			if sideToNext == TOP:
				set_height(height + h / 10)
			else:
				set_height(height + h / 5)
				
			translate(motion.normalized() * 0.75)
		else:
			set_pos(nextSpot)
			path.remove(0)
		
			if path.size() == 0:
				
				if sideToNext == TOP:
					get_node("Anim").play("idle_up")
				elif sideToNext == BOTTOM:
					get_node("Anim").play("idle_down")
				elif sideToNext == LEFT:
					get_node("Anim").play("idle_left")
				elif sideToNext == RIGHT:
					get_node("Anim").play("idle_right")
					
				#get_node("Anim").stop(true)
				isMoving = false
			else:
				update_next_spot()

func _ready():
	set_process(true)
	if world != null:
		gridPos = world.world_to_map(get_pos())
	
	offset = get_offset()
	height = 0

func order_move_to(x, y):
	
	for i in world.get_actors():
		if group != i.group:
			world.forbid_at(i.gridPos.x, i.gridPos.y)
	
	path = world.find_path(gridPos, Vector2(x, y))
	
	for i in world.get_actors():
		if group != i.group:
			world.free_at(i.gridPos.x, i.gridPos.y)
	
	#print("path size: ", path.size())
	
	#teleport_to(path[0].x, path[0].y)
	
	#print("init -> ", gridPos)
	#print("end -> ", Vector2(x, y))
	
	gridPos = Vector2(x, y)
	
	#for i in path:
	#	print("p -> ", i)
		
	if path.size() > 0:
		isMoving = true
		sideToNext = -1
		update_next_spot()
		#get_node("Anim").play("move_up")



func update_next_spot():
	var pos = world.map_to_world(Vector2(path[0].x, path[0].y)) + Vector2(0, floor(world.get_cell_size().y / 2) - 1)
	nextSpot = Vector2(pos.x, pos.y)
	nextHeight = world.get_tile_height(path[0].x, path[0].y)
	
	var angleToNext = get_angle_dg(get_pos(), nextSpot)
	
	
	var lastSide = sideToNext
	sideToNext = get_side(angleToNext)
	
	
	#get_node("Anim").stop()
	
	if sideToNext == BOTTOM:
		print("DOWN")
		if sideToNext != lastSide:
			get_node("Anim").play("move_down")
	elif sideToNext == RIGHT:
		print("RIGHT")
		if sideToNext != lastSide:
			get_node("Anim").play("move_right")
	elif sideToNext == LEFT:
		print("LEFT")
		if sideToNext != lastSide:
			get_node("Anim").play("move_left")
	elif sideToNext == TOP:
		print("TOP")
		if sideToNext != lastSide:
			get_node("Anim").play("move_up")

func teleport_to(x, y):
	var pos = world.map_to_world(Vector2(x, y))
	
	gridPos = Vector2(x, y)
	
	set_pos(pos + Vector2(0, world.get_cell_size().y / 2) )
	set_offset(offset - Vector2(0, world.get_tile_height(x, y)))


func teleport_to_v(vec):
	var pos = world.map_to_world(vec)
	
	gridPos = vec
	
	set_pos(pos + Vector2(0, world.get_cell_size().y / 2 - 1) )
	set_offset(offset - Vector2(0, world.get_tile_height(vec.x, vec.y)))

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
	
	#for i in world.get_actors():
	#	if group != i.group:
	#		world.forbid_at(i.gridPos.x, i.gridPos.y)
	
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
			
			#if world.get_unit_at(p):
			#	continue
			
			if world.get_terrainv(p) >= 0:
				var path = world.find_path(gridPos, p)
				if path.size() > 0 && path.size() <= attackRange:
					m.append(p)
	
	
	#for i in world.get_actors():
	#	if group != i.group:
	#		world.free_at(i.gridPos.x, i.gridPos.y)
	
	return m




