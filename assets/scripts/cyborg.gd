extends Node2D

#========================================= basic info

#the name of the robot
var name

#cyborg's RAM, used to store AI data
var ram

#unique identifier
var id

#badges grant improvements and special cards to the cyborg
var badges = []

var anim = "regular" setget set_anim, get_anim

export(String, "chubby", "regular", "tall") var body 

#========================================= stuff

var sprite

#========================================= equipments
var rHand
var lHand
var accessory

onready var world = get_parent()

func _ready():
	fix_sprites_offset()

func set_anim(_anim):
	anim = get_node("sprite/" + _anim)
	
	for i in get_node("sprite").get_children():
		set_hidden(true)
	
	anim.set_hidden(false)

func get_anim():
	return anim

func fix_sprites_offset():
	for i in get_node("sprite").get_children():
		i.set_offset(i.get_offset() + Vector2(0, world.get_cell_size().y / 2))