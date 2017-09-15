extends Sprite

onready var world = get_parent()
var offset
var gridPos
var path = []
var isMoving = false

export(int) var move = 2

func _ready():
	if world != null:
		gridPos = world.world_to_map(get_pos())
	
	offset = get_offset()

func order_move_to(x, y):
	path = world.find_path(gridPos, Vector2(x, y))
	isMoving = true

func teleport_to(x, y):
	var pos = world.map_to_world(Vector2(x, y))
	
	gridPos = Vector2(x, y)
	
	set_pos(pos + Vector2(0, world.get_cell_size().y / 2) )
	set_offset(offset - Vector2(0, world.get_tile_height(x, y)))

func get_movable_panels():
	
	var left = max(world.bounds.pos.x, gridPos.x - move)
	var right = min(gridPos.x + move + 1, world.bounds.pos.x + world.bounds.size.x)
	
	var top = max(world.bounds.pos.y, gridPos.y - move)
	var bottom = min(gridPos.y + move + 1, world.bounds.pos.y + world.bounds.size.y)
	
	var m = []
	
	print("gridPos", gridPos, " ----- from ", left, " to ", right)
	
	for x in range(left, right):
		for y in range(top, bottom):
			
			var p = Vector2(x, y)
			
			if world.get_terrainv(p) >= 0:
				var path = world.find_path(gridPos, p)
				if path.size() > 0 && path.size() <= move:
					m.append(p)
	
	return m




