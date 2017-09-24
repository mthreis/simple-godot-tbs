extends Control

var firstUpdate = true
var can = false
var scale = 1
var originalSize

export(NodePath) var _referenceCamera = ""
var referenceCamera

func _ready():
	originalSize = get_size()
	set_process(true)
	pass

func _process(dt):
	if Input.is_key_pressed(KEY_1):
		scale = 1
		_on_size_changed()
	
	if Input.is_key_pressed(KEY_2):
		scale = 2
		_on_size_changed()
	
	if Input.is_key_pressed(KEY_3):
		scale = 3
		_on_size_changed()
		
	
	if _referenceCamera != "":
		referenceCamera = get_node(_referenceCamera)
		
	if referenceCamera != null:
		scale = referenceCamera.zoom
	
	firstUpdate = false

func fix_position_of(d):
	var realSize = get_size() / scale
	
	realSize.x = round(realSize.x)
	realSize.y = round(realSize.y)
	
	var newPos = realSize * d.pos * scale
	
	if d.vAlign == 0:
		newPos.y = ceil(newPos.y)
	elif d.vAlign == 1:
		newPos.y -= d.get_size().y / 2
		newPos.y = round(newPos.y)
	elif d.vAlign == 2:
		newPos.y -= d.get_size().y
		newPos.y = floor(newPos.y)

	if d.hAlign   == 0:
		newPos.x   = ceil(newPos.x)
	elif d.hAlign == 1:
		newPos.x  -= d.get_size().x / 2
		newPos.x   = round(newPos.x)
	elif d.hAlign == 2:
		newPos.x  -= d.get_size().x
		newPos.x   = floor(newPos.x)

	var nH = ""
	var nV = ""
	
	if d.vAlign   == 0:
		nV = "top"
	elif d.vAlign == 1:
		nV = "middle"
	elif d.vAlign == 2:
		nV = "bottom"

	if d.hAlign   == 0:
		nH = "left"
	elif d.hAlign == 1:
		nH = "center"
	elif d.hAlign == 2:
		nH = "right"

	d.set_pos(newPos)
	#d.get_node("alignment").set_text("alignment: " + nH + " x " + nV)
	
	#d.get_node("pos").set_text("pos: " + str(d.get_pos()))

func _on_size_changed():
	#var z = max(1.0, floor(OS.get_window_size().x / 256.0))
	if !firstUpdate:
		set_scale(Vector2(scale, scale))
		set_size(OS.get_window_size() / scale)
		
		var s = OS.get_window_size()
		OS.set_window_size(Vector2(round(s.x / 2) * 2, round(s.y / 2) * 2))
		
		for i in get_children():
			fix_position_of(i)

func _on_resized():
	_on_size_changed()