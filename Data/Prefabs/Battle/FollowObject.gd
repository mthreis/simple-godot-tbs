extends Node

export var follow = ""
var f

func _ready():
	f = get_node(follow)
	set_process(true)

func _process(dt):
	if f != null:
		pass