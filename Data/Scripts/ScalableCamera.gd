extends Camera2D

export(int, "Width", "Height") var scalingReference
var target
var zoom

func _ready():
	var b = get_node("../Background")
	var bp = b.get_pos()
	var bs = b.get_size()
	set("limit/left", bp.x)
	set("limit/top", bp.y)
	set("limit/right", bp.x + bs.x)
	set("limit/bottom", bp.y + bs.y)
	
	#_target = get_node(target)
	set_process(true)
	pass

func _process(dt):
	
	#if _target != null:
	var previousZoom = zoom
		
	zoom = max(1.0, floor(OS.get_window_size().x / 280.0))
	
	
	if target != null:
		var motion = (target.get_pos() + target.get_offset() - Vector2(0, 6) ) - get_pos()
		motion -= get_viewport_rect().size / zoom / 2
		
		if previousZoom == zoom:
			translate(motion / 10)
		else:
			set_pos(target.get_pos() - target.get_offset() - Vector2(0, 6) - get_viewport_rect().size / zoom / 2)
	
	
	#target
	var s = OS.get_window_size()
	
	OS.set_window_size(Vector2(round(s.x / 2) * 2, round(s.y / 2) * 2))
#	
	set_zoom(Vector2(1.0 / zoom, 1.0 / zoom))
#	
#	var ui = get_node("../CanvasLayer/UI")
	
	#b.set_scale(Vector2(z, z))
	#b.set_size(b.originalSize / z)
	
	#if Input.is_key_pressed(KEY_R):
	#	OS.set_window_fullscreen(!OS.get_window_fullscreen())
	#set_scale(
	pass

func _on_Camera_item_rect_changed():
	set_pos(target.get_pos() - get_viewport_rect().size / zoom / 2)

