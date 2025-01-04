extends CharacterBody2D


var movement_speed = 5000

var neighbours = []

var neighbours_and_p = []
var boid_num
var player
var player_in_boid
var boid_avoid
var vel_slow = 2
@onready var raycast1 = $RayCast2D
@onready var raycast2 = $RayCast2D2
@onready var raycast3 = $RayCast2D3
@onready var raycast4 = $RayCast2D4
#@onready var raycast5 = $RayCast2D5
#@onready var raycast6 = $RayCast2D6

@onready var timer = $Timer
@onready var timer2 = $Timer2



var melee_dmg = 25

var melee_cooldown = false
var is_attacking = false
var boid_stop = false
var knockback_timer = 0
var drag_coefficient = .0001
var dir_to
var is_daddy_boid = true
var new_path_timer = 0
var area = 99
var parent
var use_tracking = false
var path_arr
var tracking_pos = 0

#offset centre, adj movement, nearby velocity
var oc = Vector2.ZERO
var am = Vector2.ZERO
var nv = Vector2.ZERO



func all_raycasts():
	var casts = [raycast1, raycast2, raycast3, raycast4]
	return casts

func all_neighbours():
	return neighbours
	
	
func does_boid_avoid():
	return boid_avoid



func boid():
	pass

func get_player():
	if player != null:
		return player
		
func in_area(new_area):
	
	print("NEW AREA")
	area = new_area
	
	
func _ready():
	parent = get_parent()
	
		
	
func _physics_process(_delta: float):
	
	
	print("boid area ", area)
	
	var player = parent.get_node("Player")
	
	if is_attacking and melee_cooldown == false: #if player is in boid 
		player.get_hit(melee_dmg)
		melee_cooldown = true
		timer2.wait_time = 2
		timer2.start()
	
	
	#var path_arr = parent.get_path_arr(position, player.position)
	
	
	
	
	
	#
	#print("velo 1", velocity)
	#
	#print("")
	#move_and_slide()
	
	
	
	
	#POSITION CHECKS TO 
	
	
	print(area, player.area, use_tracking)
	#add player velocity 
	if area == 1 and player.area == 3 and use_tracking == false:
		print("use tracking !")
		use_tracking = true
		path_arr = parent.get_path_arr(position, player.position)
		
	
	
	
	
	if use_tracking == true:
		
		print("use tracking !")
		
		print(path_arr)
		dir_to = position.direction_to(path_arr[tracking_pos])
		
		
		
		
		var v = position

		var int_pos = Vector2i(v.x, v.y)
		
		
		
		if int_pos == path_arr[path_arr.size()-1]:
			use_tracking = false
			tracking_pos = 0
		
		if int_pos == path_arr[tracking_pos]:
			tracking_pos = tracking_pos + 1
			
			

		
	else:
		
		
		dir_to = position.direction_to(player.position)
	
		rotation = lerp_angle(rotation, position.direction_to(player.position).angle(), .4)
	
		
		#take boid via A*
		#implament daddy boids
		
		
		
		
	
	
	
	
	
	
	
	if boid_avoid == true:
		
		if abs(player.position.x - position.x) < 60 and abs(player.position.y - position.y) < 60:
			am = am - (player.position - position) * 3#/250
			boid_stop = true
			#print("am: ", am)
	
	
	
	
	for i in len(neighbours):
		
		oc = oc + neighbours[i].position
		
		nv = nv + neighbours[i].velocity 
		
		if abs(neighbours[i].position.x - position.x) < 35 and abs(neighbours[i].position.y - position.y) < 35:
			am = am - (neighbours[i].position - position)/20000
			knockback_timer = 10
		
	
	if len(neighbours) != 0:
		
		oc = oc / len(neighbours)
		oc = oc.normalized()
		
		nv = nv / len(neighbours)
	
		nv = nv / 800
	
	
	#normalize boids speed when alone or in a group
		
	if len(neighbours) == 0:
		velocity = velocity /1.07
			
	
	
	#print(" ")
	#print("velo 2 ", velocity)
	#print(oc)
	#print(am)
	#print(nv)
	#print(dir_to_player)
	
	
	
	#print("vel ", velocity)
	#if boid_stop == true:
		#velocity = velocity / 2
		##velocity = velocity / vel_slow
		#vel_slow = vel_slow - 1
		#if vel_slow < 0:
			#vel_slow = 2
			#boid_stop = false
	
		
	if knockback_timer > 0:
		
		velocity -= velocity * drag_coefficient * _delta
		
		knockback_timer = knockback_timer -1 
	
	
	if velocity.length() < .3:
		velocity = Vector2.ZERO
	
	
	
	
	#velocity = velocity.normalized()
	
	
	
	#print("dir_to ", dir_to)
	#print("oc ", oc)
	#print("am ", am)
	#print("nv ", nv)
	#
	
	
	#print("dir_to ", is_daddy_boid , dir_to)
	#velocity = (dir_to + oc/2 +  am + nv) * movement_speed * _delta
	velocity = dir_to * movement_speed
	move_and_slide()
	oc = Vector2.ZERO
	am = Vector2.ZERO
	nv = Vector2.ZERO
	
	

func _on_area_2d_body_entered(body: Node2D) -> void:
	
	
	if body.has_method("player"):
		player_in_boid = true
		#print("player enter!")
		
		if body.player_rolling == true:
			boid_avoid = true
			
		else:
			is_attacking = true
			#player = body
			
			
	if (body.has_method("boid") and body.boid_num != boid_num):
		#print("appending here!!")
		neighbours.append(body)
		if is_daddy_boid == true and body.is_daddy_boid == true:
			body.is_daddy_boid = false
		#elif is_daddy_boid true and 
		
	
	
func _on_area_2d_body_exited(body: Node2D) -> void:
	
	
	if body.has_method("boid") and body.boid_num != boid_num:
		neighbours.erase(body)
		if neighbours.size() == 0 and is_daddy_boid == true:
			is_daddy_boid = false
		
	if body.has_method("player"):
		
		player_in_boid = false
		boid_avoid = false
		is_attacking = false



func _on_timer_timeout() -> void:
	pass


func _on_timer_2_timeout() -> void:
	melee_cooldown = false
