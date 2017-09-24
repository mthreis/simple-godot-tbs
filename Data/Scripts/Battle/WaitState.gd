extends Node

var actor
var manager
var caller
var arrows 

func init(_manager, _actor):
	manager = _manager
	actor = _actor

func _ready():
	arrows = preload("res://Data/Prefabs/Battle/WaitArrows.tscn").instance()
	actor.add_child(arrows)
	arrows.set_pos(Vector2(0, - 24 - actor.height ))
	
	set_process_input(true)

func _input(ev):
	if ev.is_action_pressed("ui_down"):
		arrows.set_frame(1)
		actor.get_node("Anim").play("idle_down")
		
	elif ev.is_action_pressed("ui_right"):
		arrows.set_frame(2)
		actor.get_node("Anim").play("idle_right")
		
	elif ev.is_action_pressed("ui_left"):
		arrows.set_frame(0)
		actor.get_node("Anim").play("idle_left")
		
	elif ev.is_action_pressed("ui_up"):
		arrows.set_frame(3)
		actor.get_node("Anim").play("idle_up")
	
	elif ev.is_action_pressed("ui_accept"):
		queue_free()
		arrows.queue_free()
		get_tree().set_input_as_handled()
		manager.activate(false)
		manager.manager.cursor.locked = false
		manager.manager.state = manager.manager.STATE_NAVIGATION
		manager.set_index(0)
	
	elif ev.is_action_pressed("ui_cancel"):
		queue_free()
		arrows.queue_free()
		get_tree().set_input_as_handled()
		manager.activate(true)