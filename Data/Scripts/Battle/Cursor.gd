extends Sprite

var gridPos
var world
var manager

var areaOffset

var offset

signal has_moved

var locked = false

func start():
	world = manager.world
	#areaOffset = get_node("Opacity/Area").get_pos()
	offset = get_offset().y
	if world != null:
		gridPos = world.world_to_map(get_pos())
		print("gridPos: " + str(gridPos))
	
	set_process_input(true)
	pass

func _input(ev):
	if world == null || locked:
		return
	
	var cSize = world.get_cell_size()
	var mx = cSize.x / 2
	var my = cSize.y / 2
	
	
	if ev.is_action_pressed("ui_select"):
		var u = world.get_unit_at(gridPos)
		
		if u:
			var r = Database.get_handheld(u.rHand)
			
			if r:
				print("The guy's ", u.name, " and his RHand is ", r.name, " damage: ", r.damage)
	
	if ev.is_action_pressed("ui_right"):
		
		var n = world.get_cell(gridPos.x + 1, gridPos.y)
		
		if n >= 0:
			translate(Vector2(mx, my))
			gridPos.x += 1
			set_offset(Vector2(0, offset-world.get_tile_height(gridPos.x, gridPos.y)))
			emit_signal("has_moved")

	elif ev.is_action_pressed("ui_left"):
		var n = world.get_cell(gridPos.x - 1, gridPos.y)
		
		if n >= 0:
			translate(Vector2(-mx, -my))
			gridPos.x -= 1
			set_offset(Vector2(0, offset-world.get_tile_height(gridPos.x, gridPos.y)))
			emit_signal("has_moved")
	
	elif ev.is_action_pressed("ui_up"):
		
		var n =  world.get_cell(gridPos.x, gridPos.y - 1) 
		
		if n >= 0:
			translate(Vector2(mx, -my))
			gridPos.y -= 1
			set_offset(Vector2(0, offset-world.get_tile_height(gridPos.x, gridPos.y)))
			emit_signal("has_moved")

	elif ev.is_action_pressed("ui_down"):
		
		var n = world.get_cell(gridPos.x, gridPos.y + 1)
		
		if n >= 0:
			translate(Vector2(-mx, my))
			gridPos.y += 1
			set_offset(Vector2(0, offset-world.get_tile_height(gridPos.x, gridPos.y)))
			emit_signal("has_moved")

func teleport_to(x, y):
	var pos = world.map_to_world(Vector2(x, y))
	
	gridPos = Vector2(x, y)
	
	set_pos(pos + Vector2(0, world.get_cell_size().y / 2) )
	set_offset(offset - Vector2(0, world.get_tile_height(x, y)))
	
func teleport_to_v(vec):
	var pos = world.map_to_world(vec)
	gridPos = vec
	
	set_pos(pos + Vector2(0, world.get_cell_size().y / 2 - 2) )
	set_offset(Vector2(0, offset) - Vector2(0, world.get_tile_height(vec.x, vec.y)))