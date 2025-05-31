extends CharacterBody2D
class_name Enemy

var main_scene
var dir_to
var player
var neighbours = []
var health
var move_speed = 1
var player_in_range = false
var attack_ready = true
var enemy_type
#var velocity = Vector2.ZERO

#offset centre, adj movement, nearby velocity
var oc = Vector2.ZERO
var am = Vector2.ZERO
var nv = Vector2.ZERO

func enemy():
	pass


func all_neighbours():
	return neighbours


func _ready():
	#main_scene = get_parent()
	#await get_tree().process_frame
	#player = main_scene.get_node("Player")
	#await get_tree().process_frame  # Wait for scene tree to finish connecting
	
	main_scene = get_main_scene()
	player = get_player()
	
	#main_scene = get_node("/root/main_scene")
	#player = get_node("/root/main_scene/Player")
	#player = main_scene.get_node("Player")
	
	
func get_main_scene():
	pass

func get_player():
	pass

func hit_self(dmg_amount):
	health = health - dmg_amount
	
func die():
	pass
	
func attack(player_in_range, attack_ready):
	pass
	#damage_self
func calc_velo(neighbours, on_island, move_speed, position):
	
	
	dir_to = position.direction_to(player.position)
	
	rotation = lerp_angle(rotation, position.direction_to(player.position).angle(), .4)
	
	for i in len(neighbours):
		
		oc = oc + neighbours[i].position
		
		nv = nv + neighbours[i].velocity 
		
		am = am - (neighbours[i].position - position)
			
		
	if len(neighbours) != 0:
		oc = oc / len(neighbours)
		oc = oc / 100

		nv = nv / len(neighbours)
		nv = nv / 8
		
		
		if (on_island):
			move_speed = 2.4
		else:
			move_speed = 1.7
		
	else:
		if (on_island):
			move_speed = 2.1
		else:
			move_speed = 1.5
			
	if enemy_type == "big_duck":
		oc = Vector2.ZERO
		nv = Vector2.ZERO
		move_speed = .5 
		
	print("boid speed", move_speed)
	velocity = (dir_to*20 + oc + nv) * move_speed
	

	if abs(position.x - player.position.x) < 10 and abs(position.y - player.position.y) < 10:
		velocity = Vector2.ZERO
	
	#am = Vector2.ZERO
	#velocity = Vector2.ZERO
	return velocity
