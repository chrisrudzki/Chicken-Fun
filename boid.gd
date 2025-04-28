extends CharacterBody2D


var movement_speed = 23

var neighbours = []

var boid_num
var player
var player_in_boid
var boid_avoid
var vel_slow = 2

@onready var raycast1 = $RayCast2D
@onready var raycast2 = $RayCast2D2
@onready var raycast3 = $RayCast2D3
@onready var raycast4 = $RayCast2D4

@onready var timer = $Timer
@onready var timer2 = $Timer2
@onready var knock_down_timer = $KnockdownTimer


var melee_dmg = 25

var melee_cooldown = false
var is_attacking = false
var boid_stop = false
var knockback_timer = 0
var drag_coefficient = .01
var dir_to

var new_path_timer = 0
var area = 99
var parent
var use_tracking = false
var path_arr
var tracking_pos = 4
var pl_avoid = Vector2.ZERO
var health = 100
var roll_knockback


#offset centre, adj movement, nearby velocity
var oc = Vector2.ZERO
var am = Vector2.ZERO
var nv = Vector2.ZERO

var knockback = Vector2.ZERO
var knockback_multi = 0



func all_raycasts():
	var casts = [raycast1, raycast2, raycast3, raycast4]
	return casts

func all_neighbours():
	return neighbours
	
func does_boid_avoid():
	return boid_avoid

func chicken_hit(dmg_amount):
	print("chicken hit")
	health = health - dmg_amount
	
	

func boid():
	pass

func get_player():
	if player != null:
		return player
		
func in_area(new_area):
	
	#print("NEW AREA")
	area = new_area
	
	
func _ready():
	parent = get_parent()
	
	
#func damage_self_knockback(damage_amount, knockback_multi):
	##if boid is damaged with knockback and stun
	#knockback_multi = knockback_multi
	#health = health - damage_amount
	#print("health ", health)
	#
func damage_self(damage_amount):
	#if boid is damaged without modifiers
	
	health = health - damage_amount
	print("health ", health)
	
	
func boid_player_coll():
	var player = parent.get_node("Player")
	#pl_avoid = player.position - position 
	
	if abs(position.x - player.position.x) < 1 or abs(position.y - player.position.y) < 1:
		#print("knockback multi ")
		knockback_multi = 5
		
	pl_avoid = position - player.position 
	pl_avoid = pl_avoid.normalized()

	knockback_timer = 7
	#damage_self_knockback
	
func _physics_process(_delta: float):
	
	
	if health < 0:
		$CollisionShape2D.disabled = true
		parent.boid_num = parent.boid_num -1
		queue_free()
	
	var player = parent.get_node("Player")
	
	if is_attacking and melee_cooldown == false: #if player is in boid 
		player.damage_self(melee_dmg)
		melee_cooldown = true
		timer2.wait_time = 2
		timer2.start()
	
	
	#generate path to new position if in corner adjacent square
	var v = position
	
	var int_pos = Vector2i(v.x, v.y)
		
	if area == 1 and player.area == 3 and use_tracking == false:
		print("1->3")
		use_tracking = true
		path_arr = parent.get_path_arr(position, Vector2(182,157))
		
	elif area == 4 and player.area == 2 and use_tracking == false:
		print("4->2")
		use_tracking = true
		path_arr = parent.get_path_arr(position, Vector2(89,67))

	elif area == 3 and player.area == 1 and use_tracking == false:
		print("3->1")
		use_tracking = true
		path_arr = parent.get_path_arr(position, Vector2(78,279))
		
	elif area == 2 and player.area == 4 and use_tracking == false:
		print("2->4")
		use_tracking = true
		path_arr = parent.get_path_arr(position, Vector2(195,245))
		
		
	if use_tracking == true and tracking_pos < path_arr.size():
		
		if ((path_arr[path_arr.size()-1].x)-2 <= int_pos.x and int_pos.x <= (path_arr[path_arr.size()-1].x)+2) and ((path_arr[path_arr.size()-1].y)-2 <= int_pos.y and int_pos.y <= (path_arr[path_arr.size()-1].y)+2):
			#print("AT END OF TRACKING")
			use_tracking = false
			area = 99
			tracking_pos = 4
	
		dir_to = position.direction_to(path_arr[tracking_pos])
		rotation = lerp_angle(rotation, position.direction_to(path_arr[tracking_pos]).angle(), .4)
	
		if  ((path_arr[tracking_pos].x)-1 <= int_pos.x or int_pos.x <= (path_arr[tracking_pos].x)+1 ) and (path_arr[tracking_pos].y)-1 <= int_pos.y or int_pos.y <= (path_arr[tracking_pos].y)+1 :
			tracking_pos = tracking_pos + 2
			
	else:
		
		dir_to = position.direction_to(player.position)
	
		rotation = lerp_angle(rotation, position.direction_to(player.position).angle(), .4)
	
		
	
	if boid_avoid == true:
		
		
		print("boid avoids player")
		if abs(player.position.x - position.x) < 60 and abs(player.position.y - position.y) < 60:
			
			#print("player velocity ", player.velocity.normalized() )
			
			if (player.velocity.normalized().x * (player.position - position).normalized().x) + (player.velocity.normalized().y * (player.position - position).normalized().y) > 0:
				
				am = am + (player.position - position).normalized() * ((player.velocity.normalized().x * (player.position - position).normalized().x) + (player.velocity.normalized().y * (player.position - position).normalized().y))
				#print("m new dir ", (player.velocity.normalized().x * (player.position - position).normalized().x) + (player.velocity.normalized().y * (player.position - position).normalized().y))
				#print("m player velocity x, y ", player.velocity.normalized())
				#print("m new pos dir ", (player.position - position))
				#
			else:
				
			
				am = am + (player.position - position) * 2#/250
			
			#boid_stop = true
			
			print("n here!")
			knock_down_timer.start(3)
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
	
	
	if len(neighbours) == 0:
		velocity = velocity /1.07
			
	
	
	
	dir_to = dir_to.normalized()

	velocity = (pl_avoid * knockback_multi + dir_to*1.3 + oc/2 + am + nv) * movement_speed
	
	
	if abs(position.x - player.position.x) < 10 and abs(position.y - player.position.y) < 10:
		
		velocity = Vector2.ZERO
		
		
	if velocity.length() < .3:
		velocity = Vector2.ZERO
	
	
	if boid_stop:
		velocity = Vector2.ZERO
		print("n here!3")
	
	move_and_slide()
	oc = Vector2.ZERO
	am = Vector2.ZERO
	nv = Vector2.ZERO
	
	pl_avoid = Vector2.ZERO
	knockback_multi = 1
	
	
func _on_area_2d_body_entered(body: Node2D) -> void:
	
	
	if body.has_method("rock"):
		
		chicken_hit(120)
		
	if body.has_method("bullet"):
		
		chicken_hit(10)

	if body.has_method("player"):
		
		player_in_boid = true
		#print("player enter!")
		
		
		if body.player_in_roll == true:
			
			boid_avoid = true
			
		else:
			is_attacking = true
			#player = body
			
	if (body.has_method("boid") and body.boid_num != boid_num):
		
		neighbours.append(body)
		
	
func _on_area_2d_body_exited(body: Node2D) -> void:
	
	
	if body.has_method("boid") and body.boid_num != boid_num:
		neighbours.erase(body)
		
	if body.has_method("player"):
		
		player_in_boid = false
		boid_avoid = false
		is_attacking = false

#boid_player_coll

func _on_timer_timeout() -> void:
	pass


func _on_timer_2_timeout() -> void:
	melee_cooldown = false


		
func _on_area_2d_2_body_exited(body: Node2D) -> void:
	pass # Replace with function body.
	
	
func _on_knock_down_timer_timeout() -> void:
	pass # Replace with function body.


func _on_knockdown_timer_timeout() -> void:
	boid_stop = true
	await get_tree().create_timer(1.0).timeout 
	boid_stop = false
		
	
