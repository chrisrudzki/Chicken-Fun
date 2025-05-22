extends CharacterBody2D
class_name Enemy
var main_scene
var dir_to
var player
var neighbours
#var velocity = Vector2.ZERO

#offset centre, adj movement, nearby velocity
var oc = Vector2.ZERO
var am = Vector2.ZERO
var nv = Vector2.ZERO

func all_neighbours():
	return neighbours

func _ready():
	main_scene = get_parent()
	player = main_scene.get_node("Player")
	
func die():
	pass
	
func calc_velo(neighbours, on_island, move_speed):
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
	
		

	print("boid speed", move_speed)
	velocity = (dir_to*20 + oc + nv) * move_speed
	

	if abs(position.x - player.position.x) < 10 and abs(position.y - player.position.y) < 10:
		velocity = Vector2.ZERO
	
	#am = Vector2.ZERO
	#velocity = Vector2.ZERO
	return velocity
