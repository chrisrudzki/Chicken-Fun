extends Node2D

var new_boid = preload("res://boid.tscn")
var game_over_screen = preload("res://game_over_screen.tscn")
var rock = preload("res://rock.tscn")

@onready var player = $Player
var boid_num = 0

var astar_grid

var round = 0
var round_part = 1

var round_time = 30

var round_is_done = true
var spawn_is_ready = true

var amount_spawning = 2
var freq_spawning = 2

var spawn_pos = [Vector2(-97, -37), Vector2(-174, 254), Vector2(205, 440), Vector2(409, 380)]

@onready var round_timer = $RoundTimer
@onready var spawn_timer = $SpawnTimer
#@export 

func _ready():
	
	
	astar_grid = AStarGrid2D.new()
	
	astar_grid.region = Rect2i(-153, -11, 565, 421)
	astar_grid.cell_size = Vector2(16, 16)
	astar_grid.update()
	
	#print("here")
	print(astar_grid.get_id_path(Vector2i(0, 0), Vector2i(3, 4))) # prints (0, 0), (1, 1), (2, 2), (3, 3), (3, 4)
	print(astar_grid.get_point_path(Vector2i(0, 0), Vector2i(3, 4))) # prints (0, 0), (16, 16), (32, 32), (48, 48), (48, 64)
	
	
	
func get_path_arr(boid_postion, player_position):
	
	return astar_grid.get_id_path(boid_postion, player_position)
	
	
	
func _physics_process(delta: float) -> void:
	
	if player.health <= 0:
		Global.current_round = round
		get_tree().change_scene_to_packed(game_over_screen)
		
	if round_is_done == false:
	
		if spawn_is_ready:
			spawn_timer.start(freq_spawning)
			spawn_is_ready = false
			for i in range(amount_spawning):
				var ins = new_boid.instantiate()
				ins.boid_num = boid_num + 1
				boid_num = boid_num + 1
		
				ins.position =  spawn_pos[randi() % spawn_pos.size()]
		
				add_child(ins)
		
		
	
	
	elif boid_num == 0:
		
			
		change_round()
		
		
		round_timer.start(round_time)
		round_is_done = false
		
		
	else:
		pass
		
	
func change_round():
	
	round = round + 1
	
	#round 1 hardcoded as
	#round_time: 120
	#amount_spawning: 1
	#freq_spawning: 3
	
	if round == 1:
		pass
	
	elif round == 2:
		print("START OF ROUND 2")
		#round_time = 120
		amount_spawning = 2
		freq_spawning = 2
		
		
	elif round == 3:
		amount_spawning = 2
		freq_spawning = 1
		print("START OF ROUND 3")
		
	else:
		amount_spawning = 0
		print("END OF GAME ")
		
	
	

func inst(pos):
	var ins = new_boid.instantiate()
	
	ins.boid_num = boid_num + 1
	boid_num = boid_num + 1
	ins.position = pos
	
	add_child(ins)
	

func _on_round_timer_timeout() -> void:
	
	round_is_done = true
	
func _on_spawn_timer_timeout() -> void:
	spawn_is_ready = true
