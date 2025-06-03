extends Node2D

#var new_boid = preload("res://boid.tscn")
var game_over_screen = preload("res://game_over_screen.tscn")
var rock = preload("res://rock.tscn")
var new_duck = preload("res://Duck.tscn")
var big_duck = preload("res://BigDuck.tscn")


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

var can_quack_noise = true


var all_spawn_pos = [Vector2(-250, -170), Vector2(-350, 1820), Vector2(-250, 490), Vector2(370, 700), Vector2(950, 450), Vector2(1200, 182), Vector2(1200, 182), Vector2(100, -112), Vector2(390, -200)]
#var spawn_pos 
var spawn_pos = [Vector2(-250, -170), Vector2(950, 450)]
#250, 200 and 580, 200
@onready var round_timer = $RoundTimer
@onready var spawn_timer = $SpawnTimer
@onready var spawn_pos_timer = $SpawnPosTimer

#@onready var money_label = $CanvasLayer/Control/HBoxContainer/MarginContainer3/Money_Label
@onready var money_label = $CanvasLayer/Control2/HBoxContainer/MarginContainer/Label


func _ready():
	
	
	round_timer.start(5)
	
	astar_grid = AStarGrid2D.new()
	
	astar_grid.region = Rect2i(-153, -11, 565, 421)
	astar_grid.cell_size = Vector2(16, 16)
	astar_grid.update()
	spawn_pos_timer.start(30)
	
	
	var ins = big_duck.instantiate()
	boid_num = boid_num + 1
	ins.boid_num = boid_num
		
	var boid_position = spawn_pos[randi() % spawn_pos.size()]
			
	boid_position.x = boid_position.x + randi_range(-100, 100)
	boid_position.y = boid_position.y + randi_range(-100, 100)
			
	ins.position = boid_position
			
	add_child(ins)
	
	
func get_path_arr(boid_postion, player_position):
	
	return astar_grid.get_id_path(boid_postion, player_position)
	
	
func _physics_process(delta: float) -> void:
	
	print("im quacking", boid_num, can_quack_noise)
	
	if boid_num > 1 and can_quack_noise:
		print("im quacking")
		$duckQuack.play()
		can_quack_noise = false
		$duckNoiseTimer.start(10)
		
	
	
	money_label.text = str(money)
	
	#print("boid num ", boid_num)
	print("all spawn pos ", spawn_pos[0], spawn_pos[1])
	
	if player.health <= 0:
		Global.current_round = round
		get_tree().change_scene_to_packed(game_over_screen)
		
	
	#if round_is_done == false:
	
	if spawn_is_ready and boid_num < 350:
		spawn_timer.start(freq_spawning)
		spawn_is_ready = false
		for i in range(amount_spawning):
			var ins = new_duck.instantiate()
			boid_num = boid_num + 1
			ins.boid_num = boid_num
		
			var boid_position = spawn_pos[randi() % spawn_pos.size()]
			
			boid_position.x = boid_position.x + randi_range(-100, 100)
			boid_position.y = boid_position.y + randi_range(-100, 100)
			
			ins.position = boid_position
			
			add_child(ins)
	
	
	#elif boid_num == 0:
		
	if round_is_done:
		
		print("round is done called ")
		change_round()
		round_is_done = false
		round_timer.start(round_time)
	#round_is_done = false
		
func duck_death_sound():
	$duckDeath.play()
		
	
func change_round():
	
	round = round + 1
	
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
		
	
	
	
func _on_round_timer_timeout() -> void:
	round_is_done = true
	
func _on_spawn_timer_timeout() -> void:
	spawn_is_ready = true



func _on_shop_area_body_entered(body: Node2D) -> void:
	
	if body.has_method("player"):
		body.can_shop = true
		

func _on_shop_area_body_exited(body: Node2D) -> void:
	
	if body.has_method("player"):
		body.can_shop = false

func _on_island_area_body_entered(body: Node2D) -> void:
	if body.has_method("boid"):
		body.on_island = true
		body.walk()
		
	elif body.has_method("player"):
		body.on_island = true
		body.move_speed = body.move_speed + 11000
		

func _on_island_area_body_exited(body: Node2D) -> void:
	if body.has_method("boid"):
		body.on_island = false
		body.swim()
		
	elif body.has_method("player"):
		body.on_island = false
		body.move_speed = body.move_speed - 11000
		


func _on_spawn_pos_timer_timeout() -> void:
	var index_1 = randi() % all_spawn_pos.size()
	
	var index_2 = index_1
	while index_2 == index_1:
		index_2 = randi() % all_spawn_pos.size()
	
	spawn_pos[0] = all_spawn_pos[index_1]
	spawn_pos[1] = all_spawn_pos[index_2]
	
	
	spawn_pos_timer.start(10)


func _on_duck_noise_timer_timeout() -> void:
	can_quack_noise = true
