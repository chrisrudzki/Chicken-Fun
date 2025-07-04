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

var on_island = false

# offset centre mass of neighbouring boids
var oc = Vector2.ZERO

# distance away from neighbouring objects
var am = Vector2.ZERO

# velocity of neighbouring boids
var nv = Vector2.ZERO

func enemy():
	pass

func all_neighbours():
	return neighbours

func _ready():
	
	main_scene = get_main_scene()
	player = get_player()
	
func get_main_scene():
	pass

func get_player():
	pass

func hit_self(dmg_amount):
	health = health - dmg_amount
	
func die():
	pass
	
func attack(player_in_range, attack_ready):
	# method determined by child
	
	pass
	
func calc_velo(neighbours, on_island, move_speed, position):
	# determine entity velocity
	
	dir_to = position.direction_to(player.position)
	
	rotation = lerp_angle(rotation, position.direction_to(player.position).angle(), .4)
	
	for i in len(neighbours):
		
		# entity neighbouring positions
		oc = oc + neighbours[i].position
		
		# entity neighbouring velocity
		nv = nv + neighbours[i].velocity 
		
		# distance away from neighbouring objects
		am = am - (neighbours[i].position - position)
		# not used in implamentation
		
		
	if len(neighbours) != 0:
		oc = oc / len(neighbours)
		oc = oc / 100

		nv = nv / len(neighbours)
		nv = nv / 8
		
	if enemy_type == "big_duck":
		# no flocking for big duck enemy
		
		oc = Vector2.ZERO
		nv = Vector2.ZERO
		
	
	velocity = (dir_to*20 + oc + nv) * move_speed

	# stop moving if next to player
	if abs(position.x - player.position.x) < 10 and abs(position.y - player.position.y) < 10:
		velocity = Vector2.ZERO
	
	return velocity
