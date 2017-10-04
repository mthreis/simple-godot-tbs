extends Node

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass

func get_handheld(name):
	var h = get_node("Equipments/Handhelds").find_node(name)
	
	if h == null:
		print("ISSUE: the handheld called ", name, " could NOT be found!")
		
	return h


func get_actor_ref(name):
	var h = get_node("Actors").find_node(name)
	
	if h == null:
		print("ISSUE: the actorRef called ", name, " could NOT be found!")
		
	return h

