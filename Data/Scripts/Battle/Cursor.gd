extends Sprite

var gridPos
var world
var manager

func start():
	world = manager.world
	
	
	if world != null:
		gridPos = world.world_to_map(get_pos())
		print("gridPos: " + str(gridPos))
	
	set_process_input(true)
	pass

func _input(ev):
	if world == null:
		return
	
	var cSize = world.get_cell_size()
	var mx = cSize.x / 2
	var my = cSize.y / 2
	
	if ev.is_action_pressed("ui_right"):
		
		var n = world.get_cell(gridPos.x + 1, gridPos.y)
		
		if n >= 0:
			translate(Vector2(mx, my))
			gridPos.x += 1
			set_offset(Vector2(0, -world.get_tile_height(gridPos.x, gridPos.y)))

	elif ev.is_action_pressed("ui_left"):
		var n = world.get_cell(gridPos.x - 1, gridPos.y)
		
		if n >= 0:
			translate(Vector2(-mx, -my))
			gridPos.x -= 1
			set_offset(Vector2(0, -world.get_tile_height(gridPos.x, gridPos.y)))
	
	elif ev.is_action_pressed("ui_up"):
		
		var n =  world.get_cell(gridPos.x, gridPos.y - 1) 
		
		if n >= 0:
			translate(Vector2(mx, -my))
			gridPos.y -= 1
			set_offset(Vector2(0, -world.get_tile_height(gridPos.x, gridPos.y)))

	elif ev.is_action_pressed("ui_down"):
		
		var n = world.get_cell(gridPos.x, gridPos.y + 1)
		
		if n >= 0:
			translate(Vector2(-mx, my))
			gridPos.y += 1
			set_offset(Vector2(0, -world.get_tile_height(gridPos.x, gridPos.y)))
	
#	elif ev.is_action_pressed("ui_accept"):
#		var actor = get_node("../Actor")
#		
#		var path = world.find_path(actor.gridPos, gridPos)
#		
#		if path.size() > 0:
#			actor.teleport_to(gridPos.x, gridPos.y)
#			print("Path count: " + str(path.size()))