extends Node

var manager
var actor
var world

var caller
var actorHitInfo
var markers = []

var isAttacking = false

var spots
var targettableUnits = []
var tween
var waitForAttack = false
var color = 0.0

var cursorPos
var cursorGridPos
var found = null

func init(_manager, _actor):
	manager = _manager
	actor = _actor
	world = manager.world
	
	cursorPos = manager.cursor.get_pos()
	cursorGridPos = manager.cursor.gridPos

func on_cursor_has_moved():
	found = null
	for i in spots:
		if manager.cursor.gridPos == i:
			found = world.get_unit_at(manager.cursor.gridPos) 
	
	var h = manager.hitInfo
	
	if found != null:
		#print("Found ", found.name)
		
		actorHitInfo = actor.get_hit_info(found)
		
		h.set_hidden(false)
		h.get_node("Damage/Value").set_text(str(actorHitInfo["damage"]))
		h.get_node("Chance/Value").set_text(str(actorHitInfo["chance"]))
	else:
		h.set_hidden(true)

func _ready():
	set_process(true)
	set_process_input(true)
	
	manager.selected = actor
	manager.state = manager.STATE_ACT
	spots = actor.get_targettable_panels()
	
	manager.cursor.connect("has_moved", self, "on_cursor_has_moved")
	
	#
	for i in spots:
		var mk = preload("res://Data/Prefabs/ActMarker.tscn").instance()
		manager.world.add_child(mk)
		mk.set_owner(manager.world)
		
		mk.set_pos(manager.world.map_to_world(i))
		mk.set_offset(mk.offset - Vector2(0, world.get_tile_height(i.x, i.y)))
		
		var unitAt = world.get_unit_at(i)
		
		if unitAt != null:
			targettableUnits.append(unitAt)
		
		markers.append(mk)
	
	#
	tween = Tween.new()
	tween.interpolate_property(self, "color", 0.0, 0.5, 1.0, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.set_repeat(true)
	tween.start()
	
	add_child(tween)

func _input(ev):
	if ev.is_action_pressed("ui_cancel"):
		print("UECRL")
		if caller != null:
			var h = manager.hitInfo
			h.set_hidden(true)
			
			get_tree().set_input_as_handled()
			manager.cursor.locked = true
			manager.cursor.teleport_to_v(actor.gridPos)
			
			var h = manager.actorInfo
			h.set_hidden(false)
			h.get_node("Actor").set_text(str(actor.name))
			h.get_node("HP/Value").set_text(str(actor.HP, "/", actor.maxHP))
			h.get_node("MP/Value").set_text(str(actor.MP, "/", actor.maxMP))
			
			cleanup()
			end()
	
	elif ev.is_action_pressed("ui_accept"):
		if found != null:
			actor.start_attack(found, actorHitInfo)
			waitForAttack = true
			
			manager.hitInfo.set_hidden(true)
			manager.cursor.set_hidden(true)
			manager.cursor.locked = true
			
			cleanup()
			
#			get_tree().set_input_as_handled()
#			manager.cursor.locked = true
#			manager.cursor.teleport_to_v(actor.gridPos)
#			
#			var h = manager.actorInfo
#			h.set_hidden(false)
#			h.get_node("Actor").set_text(str(actor.name))
#			h.get_node("HP/Value").set_text(str(actor.HP, "/", actor.maxHP))
#			h.get_node("MP/Value").set_text(str(actor.MP, "/", actor.maxMP))
#			
#			var dam = preload("res://Data/Prefabs/Battle/DamagePopup.tscn").instance()
#			dam.get_node("Value").set_text(str(d))
#			found.add_child(dam)
			
			
			#end()

func cleanup():
	for i in markers:
		i.queue_free()
	
	for i in targettableUnits:
		i.set_modulate(Color(1.0, 1.0, 1.0, 1.0))

func _process(dt):
	
	if waitForAttack:
		if !actor.isAttacking:
			end()
	else:
		for i in targettableUnits:
			i.set_modulate(Color(0.8, color, color, 1.0))

func end():
	#for i in markers:
	#	i.queue_free()
	
	#spots.clear()
	
	#for i in targettableUnits:
	#	i.set_modulate(Color(1.0, 1.0, 1.0, 1.0))
	
	manager.cursor.set_hidden(false)
	manager.cursor.teleport_to_v(actor.gridPos)
	
	
	if caller != null:
		caller.activate(true)
		
	manager.actState = null
	queue_free()