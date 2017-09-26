extends Node

onready var world = get_node("../World")

const STATE_NAVIGATION = 0
const STATE_MOVE = 2
const STATE_WAIT_MOVE = 5
const STATE_ACT = 3
const STATE_WAIT = 6

export var height = 1

onready var hitInfo = get_node("Canvas/UI/HitInfo")
onready var actorInfo = get_node("Canvas/UI/ActorInfo")

var backToMenu = true

signal has_entered_actions_menu

#var ActStateHandler = preload("res://Data/Scripts/Battle/ActState.gd")
var actState
var moveState

var markers = []

export(Color) var enemyColor
export(Color) var allyColor


var selected
var movable
var targettable
var state = STATE_NAVIGATION

var canvas
var cursor

func _input(event):
	if event.is_action_pressed("ui_accept"):
		
		if state == STATE_NAVIGATION:
			var hovered = world.get_unit_at(cursor.gridPos)
			
			if hovered != null:
				emit_signal("has_entered_actions_menu", self, hovered)
				cursor.locked = true



#	if event.is_action_pressed("ui_act"):
#		if state == STATE_NAVIGATION:
#			var hovered = world.get_unit_at(cursor.gridPos)
#			
#			if hovered != null:
#				start_act_phase(hovered)
#	
#	elif event.is_action_pressed("ui_accept"):
#		
#		if state == STATE_NAVIGATION:
#			var hovered = world.get_unit_at(cursor.gridPos)
#			
#			if hovered != null:
#				emit_signal("has_entered_actions_menu", self, hovered)
#				cursor.locked = true
#		
#		elif state == STATE_MOVE:
#			var available = false
#			
#			for i in movable:
#				if cursor.gridPos == i:
#					available = true
#					break
#			
#			if available:
#				state = STATE_WAIT_MOVE
#				cursor.locked = true
#				
#				world.set_unit_at(selected.gridPos, null)
#				selected.order_move_to(cursor.gridPos.x, cursor.gridPos.y)
#				world.set_unit_at(cursor.gridPos, selected)
#				#state = STATE_NAVIGATION
#				
#				for i in markers:
#					i.queue_free()
#				markers.clear()
#	
#	elif event.is_action_pressed("ui_cancel"):
#		pass
#		print("ue")
#		for i in markers:
#			i.queue_free()
#		
#		markers.clear()
#		
#		if actState != null:
#			print("nnnn")
#			actState.end()
#		
#		
#		state = STATE_NAVIGATION
		
		
		
#		selected = world.get_node("Actor")
#		movable = selected.get_movable_panels()
#		var marker = preload("res://Data/Prefabs/MoveMarker.tscn")
#		
#		print("count: ", movable.size())
#		
#		for i in movable:
#			var mk = marker.instance()
#			world.add_child(mk)
#			mk.set_owner(world)
#			
#			mk.set_pos(world.map_to_world(i) + Vector2(0, world.get_cell_size().y / 2 - 1))
#			mk.set_offset(mk.offset - Vector2(0, world.get_tile_height(i.x, i.y)))
#			
#			markers.append(mk)
		
		
		#world.set_y_sort_mode(true)

			#var c = cursor.gridPos == i.gridPos + Vector2(-1, -1)
			#if world.get_unit_at(Vector2(i.gridPos.x - 1, i.gridPos.y - 1)) != null || c:
			#	i.set_opacity(max(0.5, i.get_opacity() - 0.025))
			#else:
			#	i.set_opacity(min(1.0, i.get_opacity() + 0.025))
				

func on_cursor_has_moved():
	
	#if state != STATE_MENU:
	var found = world.get_unit_at(cursor.gridPos) 
	
	var h = actorInfo
	
	if found != null:
		#print("Found ", found.name)
		
		h.set_hidden(false)
		h.get_node("Actor").set_text(str(found.name))
		h.get_node("HP/Value").set_text(str(found.HP, "/", found.maxHP))
		h.get_node("MP/Value").set_text(str(found.MP, "/", found.maxMP))
		
		var color
		
		if found.group == 0:
			color = allyColor
		else:
			color = enemyColor
		
		#h.get_node("Actor").set("custom_colors/font_color", color)
		
		#h.get_node("Chance/Value").set_text(str(actor.chance))
	else:
		h.set_hidden(true)


func _ready():
	
	
	set_process(true)
	set_process_input(true)
	cursor = get_node("Cursor")
	cursor.manager = self
	
	cursor.connect("has_moved", self, "on_cursor_has_moved")
	
	canvas = get_node("Canvas/UI")
	canvas.referenceCamera = get_node("../Camera")
	
	canvas.referenceCamera.target = cursor
	
	remove_child(cursor)
	world.add_child(cursor)
	cursor.set_owner(world)
	cursor.start()
	
	for i in world.get_children():
		if i.is_in_group("Actors"):
			print("IE")
			world.set_unit_at(world.world_to_map(i.get_pos()), i)


func _process(delta):
	pass
#	if state == STATE_WAIT_MOVE:
#		if selected != null:
#			if !selected.isMoving:
#				state = STATE_NAVIGATION
#				cursor.locked = false



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

func start_act_phase(actor):
	actState = preload("res://Data/Prefabs/Battle/ActState.tscn").instance()
	actState.init(self, actor)
	
	add_child(actState)

func start_move_phase_from_caller(actor, _caller):
	moveState = preload("res://Data/Prefabs/Battle/MoveState.tscn").instance()
	moveState.init(self, actor)
	
	moveState.caller = _caller
	
	add_child(moveState)

func start_act_phase_from_caller(actor, _caller):
	actState = preload("res://Data/Prefabs/Battle/ActState.tscn").instance()
	actState.init(self, actor)
	
	actState.caller = _caller
	
	add_child(actState)