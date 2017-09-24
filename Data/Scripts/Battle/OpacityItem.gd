extends Area2D

var objectsUnder = 0

func _ready():
	set_process(true)
	pass

func _process(delta):
	if objectsUnder <= 0:
		get_parent().set_opacity(min(1.0, get_parent().get_opacity() + 0.025))
	else:
		get_parent().set_opacity(max(0.5, get_parent().get_opacity() - 0.025))

func _on_Opacity_area_enter( area ):
	if area.get_parent().is_in_group("Actors") || area.get_parent().is_in_group("Cursor"):
		objectsUnder += 1

func _on_Opacity_area_exit( area ):
	if area.get_parent().is_in_group("Actors") || area.get_parent().is_in_group("Cursor"):
		objectsUnder -= 1