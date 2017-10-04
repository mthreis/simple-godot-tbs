extends Control

export(int, "Top", "Middle", "Bottom") var vAlign = 0
export(int, "Left", "Center", "Right") var hAlign = 0

var pos = Vector2()
var manager
var active = false


func _ready():
	set_process_input(true)
	update_pos()
	#get_node("pos").set_text("pos:" + str(pos))

func update_pos():
	var size = get_parent().get_size()
	
	var h = 0
	var v = 0
	
	if vAlign == 0:
		v = 0
	elif vAlign == 1:
		v = get_size().y / 2
	elif vAlign == 2:
		v = get_size().y
	
	if hAlign == 0:
		h = 0
	elif hAlign == 1:
		h = get_size().x / 2
	elif hAlign == 2:
		h = get_size().x
	
	pos = (get_pos() + Vector2(h, v)) / size