extends Node

var actor
var manager
var caller

func _init(_manager, _actor):
	manager = _manager
	actor = _actor

func _ready():
	var waitArrows = preload("res://Data/Prefabs/Battle/WaitArrows.tscn").instance()
				
	actor.add_child(waitArrows)
	#waitArrows.set_owner(actor)
	waitArrows.set_pos(-Vector2(0, 24))
	set_process_input(true)
	pass

func _input(ev):
	if ev.is_action_pressed("ui_cancel"):
		queue_free()
		manager.activate(true)