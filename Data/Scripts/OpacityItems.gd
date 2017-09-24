extends Sprite

var gridPos 
onready var world = get_parent()

func _ready():
	gridPos = world.world_to_map(get_pos())