extends Sprite

onready var world = get_parent()
var offset
var gridPos
var path = []
var isMoving = false

const ALLY =  0
const ENEMY = 1

var isAttacking = false
var attackStep = 0

var rHand
var lHand
var accessory

var wounded = false

var hitInfo

export var reference = ""
#var reference

onready var timer = get_node("Timer")

var maxHP = 10
var maxMP = 10
var level = 1

var HP = maxHP
var MP = maxMP

var strength = 10
var resistance = 10
var dexterity = 10
var wisdom = 10
var side
var trueBonusHP  = 0
var trueBonusMP  = 0
var trueBonusStr = 0
var trueBonusDex = 0
var trueBonusMag = 0

var percBonusHP  = 0
var percBonusMP  = 0
var percBonusStr = 0
var percBonusDex = 0
var percBonusMag = 0

#var side = RIGHT setget set_side, get_side_

var angle = 0

func look_at(_side):
	if HP <= maxHP * 0.3:
		if sideToNext == TOP:
			set_frame(2)
			side = TOP
			angle
		elif sideToNext == BOTTOM:
			set_frame(1)
		elif sideToNext == LEFT:
			set_frame(3)
		elif sideToNext == RIGHT:
			set_frame(0)
	else:
		if sideToNext == TOP:
			get_node("Anim").play("idle_up")
		elif sideToNext == BOTTOM:
			get_node("Anim").play("idle_down")
		elif sideToNext == LEFT:
			get_node("Anim").play("idle_left")
		elif sideToNext == RIGHT:
			get_node("Anim").play("idle_right")


func set_side(_side):
	side = _side
	
	if HP <= maxHP * 0.3:
		if sideToNext == TOP:
			set_frame(2)
		elif sideToNext == BOTTOM:
			set_frame(1)
		elif sideToNext == LEFT:
			set_frame(3)
		elif sideToNext == RIGHT:
			set_frame(0)
	else:
		if sideToNext == TOP:
			get_node("Anim").play("idle_up")
		elif sideToNext == BOTTOM:
			get_node("Anim").play("idle_down")
		elif sideToNext == LEFT:
			get_node("Anim").play("idle_left")
		elif sideToNext == RIGHT:
			get_node("Anim").play("idle_right")

var canMove = true
var canAct = true

export var name = "Actor"

export(int, "Ally", "Enemy") var group = 0

const TOP = 3
const BOTTOM = 1
const RIGHT = 2
const LEFT = 0
var sideToNext = -1 

func get_angle_dg(from, to):
	var angle = (to - from).angle()
	angle = rad2deg(angle)
	angle += 180
	return angle

func get_side(angle):
	return floor(angle / 90)

var height

export(int) var move = 2

var nextSpot
var nextHeight

func set_height(v):
	height = v
	set_offset(offset - Vector2(0, height))

func _process(delta):
	
	
	
	if isMoving:
		var motion = nextSpot - get_pos()
		var h = nextHeight - height
		
		if motion.length_squared() > 0.75:
			
			if sideToNext == TOP:
				set_height(height + h / 10)
			else:
				set_height(height + h / 5)
				
			translate(motion.normalized() * 0.75)
		else:
			set_pos(nextSpot)
			path.remove(0)
		
			if path.size() == 0:
				if HP <= maxHP * 0.3:
					get_node("Anim").stop()
					
					set_master_anim("wounded")
					if sideToNext == TOP:
						set_frame(2)
					elif sideToNext == BOTTOM:
						set_frame(1)
					elif sideToNext == LEFT:
						set_frame(3)
					elif sideToNext == RIGHT:
						set_frame(0)
				else:
					if sideToNext == TOP:
						get_node("Anim").play("idle_up")
					elif sideToNext == BOTTOM:
						get_node("Anim").play("idle_down")
					elif sideToNext == LEFT:
						get_node("Anim").play("idle_left")
					elif sideToNext == RIGHT:
						get_node("Anim").play("idle_right")
			
				isMoving = false
			else:
				update_next_spot()

func equip_rhand(_name):
	var rh = Database.get_handheld(_name)
	if rh:
		rHand = rh

func equip_lhand(_name):
	var lh = Database.get_handheld(_name)
	if lh:
		lHand = lh




func _ready():
	
	var ref = Database.get_actor_ref(reference)
	
	if ref:
		print("FOUND THE REF")
		#basic stats
		name = ref.name
		
		maxHP = ref.maxHP
		maxMP = ref.maxMP
		level = ref.level
		HP = maxHP
		MP = maxMP
		
		strength = ref.strength
		resistance = ref.resistance
		dexterity = ref.dexterity
		wisdom = ref.wisdom
		
		
		equip_rhand(ref.rHand)
		equip_lhand(ref.lHand)
		
	
	timer.connect("timeout", self, "timer_has_finished")
	
	set_process(true)
	if world != null:
		gridPos = world.world_to_map(get_pos())
		teleport_to_v(gridPos)
		
		
	
	offset = get_offset()
	height = 0

func order_move_to(x, y):
	
	for i in world.get_actors():
		if group != i.group:
			world.forbid_at(i.gridPos.x, i.gridPos.y)
	
	path = world.find_path(gridPos, Vector2(x, y))
	
	for i in world.get_actors():
		if group != i.group:
			world.free_at(i.gridPos.x, i.gridPos.y)
	
	#print("path size: ", path.size())
	
	#teleport_to(path[0].x, path[0].y)
	
	#print("init -> ", gridPos)
	#print("end -> ", Vector2(x, y))
	
	gridPos = Vector2(x, y)
	
	#for i in path:
	#	print("p -> ", i)
		
	if path.size() > 0:
		set_master_anim("regular")
		
		isMoving = true
		sideToNext = -1
		update_next_spot()
		#get_node("Anim").play("move_up")



func update_next_spot():
	var pos = world.map_to_world(Vector2(path[0].x, path[0].y)) + Vector2(0, world.get_cell_size().y / 2 - 1)
	nextSpot = Vector2(pos.x, pos.y)
	nextHeight = world.get_tile_height(path[0].x, path[0].y)
	
	var angleToNext = get_angle_dg(get_pos(), nextSpot)
	
	
	var lastSide = sideToNext
	sideToNext = get_side(angleToNext)
	
	
	#get_node("Anim").stop()
	
	if sideToNext == BOTTOM:
		print("DOWN")
		if sideToNext != lastSide:
			get_node("Anim").play("move_down")
	elif sideToNext == RIGHT:
		print("RIGHT")
		if sideToNext != lastSide:
			get_node("Anim").play("move_right")
	elif sideToNext == LEFT:
		print("LEFT")
		if sideToNext != lastSide:
			get_node("Anim").play("move_left")
	elif sideToNext == TOP:
		print("TOP")
		if sideToNext != lastSide:
			get_node("Anim").play("move_up")

func teleport_to(x, y):
	var pos = world.map_to_world(Vector2(x, y))
	
	gridPos = Vector2(x, y)
	
	set_pos(pos + Vector2(0, world.get_cell_size().y / 2) )
	set_offset(offset - Vector2(0, world.get_tile_height(x, y)))


func teleport_to_v(vec):
	var pos = world.map_to_world(vec)
	
	gridPos = vec
	
	set_pos(pos + Vector2(0, world.get_cell_size().y / 2 - 1) )
	set_offset(offset - Vector2(0, world.get_tile_height(vec.x, vec.y)))

func get_movable_panels():
	
	for i in world.get_actors():
		if group != i.group:
			world.forbid_at(i.gridPos.x, i.gridPos.y)
	
	var left = max(world.bounds.pos.x, gridPos.x - move)
	var right = min(gridPos.x + move + 1, world.bounds.pos.x + world.bounds.size.x)
	
	var top = max(world.bounds.pos.y, gridPos.y - move)
	var bottom = min(gridPos.y + move + 1, world.bounds.pos.y + world.bounds.size.y)
	
	var m = []
	
	print("gridPos", gridPos, " ----- from ", left, " to ", right)
	
	for x in range(left, right):
		for y in range(top, bottom):
			
			var p = Vector2(x, y)
			
			if world.get_unit_at(p):
				continue
			
			if world.get_terrainv(p) >= 0:
				var path = world.find_path(gridPos, p)
				if path.size() > 0 && path.size() <= move:
					m.append(p)
	
	
	for i in world.get_actors():
		if group != i.group:
			world.free_at(i.gridPos.x, i.gridPos.y)
	
	return m




func get_targettable_panels():
	
	var rHr = 0
	var lHr = 0
	
	var rn = 0
	
	if rHand:
		rHr = rHand.radius
	
	if lHand:
		lHr = lHand.radius
	
	
	
	var attackRange = max(1, rHr)
	
	
	var left = max(world.bounds.pos.x, gridPos.x - attackRange)
	var right = min(gridPos.x + attackRange + 1, world.bounds.pos.x + world.bounds.size.x)
	
	var top = max(world.bounds.pos.y, gridPos.y - attackRange)
	var bottom = min(gridPos.y + attackRange + 1, world.bounds.pos.y + world.bounds.size.y)
	
	var m = []
	
	print("gridPos", gridPos, " ----- from ", left, " to ", right)
	
	for x in range(left, right):
		for y in range(top, bottom):
			
			var p = Vector2(x, y)
			
			#it's me .-.
			if p == gridPos:
				continue
			
			#if world.get_unit_at(p):
			#	continue
			
			if world.get_terrainv(p) >= 0:
				var path = world.find_path(gridPos, p)
				if path.size() > 0 && path.size() <= attackRange:
					m.append(p)
	
	
	#for i in world.get_actors():
	#	if group != i.group:
	#		world.free_at(i.gridPos.x, i.gridPos.y)
	
	return m

func equip_accessory(name):
	var h = Database.get_accessory(name)
	
	#if h != null:
		

func get_damage(_target):
	return 

func get_hit_info(_target):
	
	var dam = 0
	var anim = ""
	var chance = 0
	
	if rHand != null && rHand.radius > 0:
		dam += rHand.get_damage(self, _target)
		anim = rHand.type
	
	if lHand != null && lHand.radius > 0:
		dam += lHand.get_damage(self, _target)
		anim = lHand.type
	
	var info = {}
	
	info["target"] = _target
	info["anim"]   = anim
	info["damage"] = dam
	info["chance"] = 85
	
	print("UD: ", info)
	return info

func start_attack(_target, hit):
	hitInfo = hit
	
	look_at_actor(hitInfo["target"])
	timer.set_wait_time(0.5)
	timer.start()
	
	isAttacking = true
	attackStep = 0
	
	canAct = false

func timer_has_finished():
	if isAttacking:
		if attackStep == 0:
			attack_deal()
			timer.set_wait_time(0.7)
			timer.start()
			attackStep = 1
		elif attackStep == 1:
			isAttacking = false

func attack_deal():
	print("DEALT")
	var dam = preload("res://Data/Prefabs/Battle/DamagePopup.tscn").instance()
	dam.get_node("Value").set_text(str(hitInfo["damage"]))
	hitInfo["target"].add_child(dam)
	
	var prevHP = hitInfo["target"].HP
	
	hitInfo["target"].HP -= hitInfo["damage"]
	
	
	var t = hitInfo["target"]
	
	if t.HP <= t.maxHP * 0.3:
		t.wounded = true
		t.set_master_anim("wounded")
	
	
	var hb = preload("res://Data/Prefabs/Battle/HealthBar.tscn").instance()
	hb.init(t.maxHP, prevHP, t.HP)
	t.add_child(hb)
	
	#var c = world.get_node("../Camera")
	#c.set_pos(c.get_pos() - Vector2(25, 0))

func set_master_anim(_anim):
	var a = get_node("Anim/" + _anim)
	if a != null:
		print("pqpqp")
		set_texture(a.get_texture())
		set_hframes(a.get_hframes())
		set_vframes(a.get_vframes())
		set_frame(0)

func look_at_actor(_actor):
	var angle = get_angle_dg(get_pos(), _actor.get_pos())
	var side  = get_side(angle)
	
	if side == TOP:
		get_node("Anim").play("idle_up")
	elif side == BOTTOM:
		get_node("Anim").play("idle_down")
	elif side == LEFT:
		get_node("Anim").play("idle_left")
	elif side == RIGHT:
		get_node("Anim").play("idle_right")