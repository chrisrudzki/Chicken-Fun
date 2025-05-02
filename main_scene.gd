extends Node2D

var new_boid = preload("res://boid.tscn")
var game_over_screen = preload("res://game_over_screen.tscn")
var rock = preload("res://rock.tscn")

@onready var player = $Player
var boid_num = 0
var astar_grid

var round = 0
var round_part = 1

var round_time = 5

var money: int

var round_is_done = false
var spawn_is_ready = true

var amount_spawning = 0
var freq_spawning = .5

var spawn_pos = [Vector2(-450, -117), Vector2(-155, -300), Vector2(450, -250), Vector2(714, -51), Vector2(860, 150), Vector2(540, 670), Vector2(190, 740), Vector2(-270, 610)]

@onready var round_timer = $RoundTimer
@onready var spawn_timer = $SpawnTimer

@onready var money_label = $CanvasLayer/Control/HBoxContainer/MarginContainer3/Money_Label
@onready var round_label = $CanvasLayer/Control2/HBoxContainer/MarginContainer/Label


func _ready():
	
	
	round_timer.start(5)
	
	astar_grid = AStarGrid2D.new()
	
	astar_grid.region = Rect2i(-153, -11, 565, 421)
	astar_grid.cell_size = Vector2(16, 16)
	astar_grid.update()
	
	#print("here")
	#print(astar_grid.get_id_path(Vector2i(0, 0), Vector2i(3, 4))) # prints (0, 0), (1, 1), (2, 2), (3, 3), (3, 4)
	#print(astar_grid.get_point_path(Vector2i(0, 0), Vector2i(3, 4))) # prints (0, 0), (16, 16), (32, 32), (48, 48), (48, 64)
	
func get_path_arr(boid_postion, player_position):
	
	return astar_grid.get_id_path(boid_postion, player_position)
	
	
func _physics_process(delta: float) -> void:
	
	money_label.text = str(money)
	
	print("boid num ", boid_num)
	
	if player.health <= 0:
		Global.current_round = round
		get_tree().change_scene_to_packed(game_over_screen)
		
	
	#if round_is_done == false:
	
	if spawn_is_ready and boid_num < 350:
		spawn_timer.start(freq_spawning)
		spawn_is_ready = false
		for i in range(amount_spawning):
			var ins = new_boid.instantiate()
			boid_num = boid_num + 1
			ins.boid_num = boid_num
		
			var boid_position = spawn_pos[randi() % spawn_pos.size()]
			
			boid_position.x = boid_position.x + randi_range(-130, 130)
			boid_position.y = boid_position.y + randi_range(-130, 130)
			
			ins.position = boid_position
			
			add_child(ins)
	
	
	#elif boid_num == 0:
		
	if round_is_done:
		
		print("round is done called ")
		change_round()
		round_is_done = false
		round_timer.start(round_time)
	#round_is_done = false
		
		
	
func change_round():
	
	#round_label.text = str(round)
	round = round + 1
	round_label.text = str(round)
	#print("round", round)
	#money_label.text = str(round)
	#round 1 hardcoded as
	#round_time: 30
	#amount_spawning: 1
	#freq_spawning: 3
	
	if round == 1:
		print("START OF ROUND 1")
		round_time = 30
		amount_spawning = 1
		freq_spawning = 1.2
	
	elif round == 2:
		print("START OF ROUND 2")
		round_time = 30
		amount_spawning = 1
		freq_spawning = .9
		
	elif round == 3:
		round_time = 40
		amount_spawning = 1
		freq_spawning = .3
		print("START OF ROUND 3")
		
	elif round == 4:
		round_time = 40
		amount_spawning = 1
		freq_spawning = 0.2
		print("START OF ROUND 4")
		
	elif round == 5:
		round_time = 40
		amount_spawning = 1
		freq_spawning = .1
		print("START OF ROUND 5")
	
	else:
		round_time = round_time + 5
		if freq_spawning > .025:
			freq_spawning = freq_spawning - .025
		
		
		print("NEXT ROUND")
		
	
		
	
	
func inst(pos):
	var ins = new_boid.instantiate()
	
	ins.boid_num = boid_num + 1
	boid_num = boid_num + 1
	ins.position = pos
	ins.money_label = $CanvasLayer/Control/HBoxContainer/MarginContainer3/Money_Label
	add_child(ins)
	
func _on_round_timer_timeout() -> void:
	round_is_done = true
	
func _on_spawn_timer_timeout() -> void:
	spawn_is_ready = true



func _on_area_2d_5_body_entered(body: Node2D) -> void:
	
	if body.has_method("boid"):
		body.move_speed = body.move_speed + 21
	
	elif body.has_method("player"):
		
		body.move_speed = body.move_speed + 15000
		
	
	#edit the player or boids speed here !!!!


func _on_area_2d_5_body_exited(body: Node2D) -> void:
	
	if body.has_method("boid"):
		body.move_speed = body.move_speed - 21
	
	elif body.has_method("player"):
		body.move_speed = body.move_speed - 15000
		
