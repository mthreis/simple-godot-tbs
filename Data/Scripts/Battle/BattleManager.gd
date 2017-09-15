extends Node

onready var world = get_node("../World")

const STATE_NAVIGATION = 0
const STATE_MOVE = 2

var markers = []

var selected
var movable
var state = STATE_NAVIGATION

var cursor

func _input(event):
	
	if event.is_action_pressed("ui_accept"):
		
		if state == STATE_NAVIGATION:
			var hovered = world.get_unit_at(cursor.gridPos)
			
			if hovered != null:
				start_move_phase(hovered)
		
		elif state == STATE_MOVE:
			#var path = world.find_path(actor.gridPos, gridPos)
		
			#if path.size() > 0:
			
			var available = false
			
			for i in movable:
				if cursor.gridPos == i:
					available = true
					break
			
			if available:
				
				world.set_unit_at(selected.gridPos, null)
				
				selected.teleport_to(cursor.gridPos.x, cursor.gridPos.y)
				
				world.set_unit_at(selected.gridPos, selected)
				
				state = STATE_NAVIGATION
				
				
				for i in markers:
					i.queue_free()
				markers.clear()
	
	if event.is_action_pressed("ui_cancel"):
		
		print("ue")
		for i in markers:
			i.queue_free()
		
		markers.clear()
		
		selected = world.get_node("Actor")
		movable = selected.get_movable_panels()
		var marker = preload("res://Data/Prefabs/MoveMarker.tscn")
		
		print("count: ", movable.size())
		
		for i in movable:
			var mk = marker.instance()
			world.add_child(mk)
			mk.set_owner(world)
			
			mk.set_pos(world.map_to_world(i) + Vector2(0, world.get_cell_size().y / 2 - 1))
			mk.set_offset(mk.offset - Vector2(0, world.get_tile_height(i.x, i.y)))
			
			markers.append(mk)
		
		
		#world.set_y_sort_mode(true)

func _ready():
	set_process_input(true)
	cursor = get_node("Cursor")
	cursor.manager = self
	
	remove_child(cursor)
	world.add_child(cursor)
	cursor.set_owner(world)
	cursor.start()
	
	for i in world.get_children():
		if i.is_in_group("Actors"):
			print("IE")
			world.set_unit_at(world.world_to_map(i.get_pos()), i)


func start_move_phase(actor):
	state = STATE_MOVE
	
	for i in markers:
		i.queue_free()
	
	markers.clear()
	
	selected = actor
	movable = selected.get_movable_panels()
	var marker = preload("res://Data/Prefabs/MoveMarker.tscn")
	
	print("count: ", movable.size())
	
	for i in movable:
		var mk = marker.instance()
		world.add_child(mk)
		mk.set_owner(world)
		
		mk.set_pos(world.map_to_world(i) + Vector2(0, world.get_cell_size().y / 2 - 1))
		mk.set_offset(mk.offset - Vector2(0, world.get_tile_height(i.x, i.y)))
		
		markers.append(mk)