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

export(String, "chubby", "regular", "tall", "short") var body 

#========================================= stuff

var sprite

#========================================= equipments
var rHand
var lHand
var accessory

func set_anim(_anim):
	anim = get_node("sprite/" + _anim)
	
	for i in get_node("sprite").get_children():
		set_hidden(true)
	
	anim.set_hidden(false)

func get_anim():
	return anim