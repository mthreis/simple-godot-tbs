extends Node

export var name = "New Handheld"

# types are: knife, sword, spear, bow, rod, shield
export(String, "knife", "sword", "spear", "bow", "rod" , "shield") var type = "knife"
export(String, "physical", "magical", "mixed") var damageType = "physical"

export var damage = 1
export var radius = 1
export var evasion = 0

func get_damage(owner, target):
	if damageType == "physical":
		return max(0, ceil((damage + owner.strength / 2) - target.resistance / 4))
		
	elif damageType == "magical":
		return max(0, ceil((damage + owner.wisdom / 2) - target.resistance / 8))
		
	elif damageType == "mixed":
		return max(0, ceil((damage + owner.wisdom / 4 + owner.strength / 4)) - target.resistance / 6)
		
	else:
		return 9999 #if this happened, some weird crap happened '-'