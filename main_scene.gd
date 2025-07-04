extends Node2D

var game_over_screen = preload("res://game_over_screen.tscn")

var rock = preload("res://rock.tscn")

var new_duck = preload("res://Duck.tscn")

var big_duck = preload("res://BigDuck.tscn")

var mallard = preload("res://mallard.tscn")

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

var special_round = false

var can_spawn_big_duck = false

var all_spawn_pos = [Vector2(-250, -170), Vector2(-350, 1820), Vector2(-250, 490), Vector2(370, 700), Vector2(950, 450), Vector2(1200, 182), Vector2(1200, 182), Vector2(100, -112), Vector2(390, -200)]

# current spawn positions
var spawn_pos = [Vector2(-250, -170), Vector2(950, 450)]

@onready var round_timer = $RoundTimer

@onready var spawn_timer = $SpawnTimer

@onready var spawn_pos_timer = $SpawnPosTimer

@onready var big_duck_timer = $bigDuckTimer

@onready var money_label = $CanvasLayer/Control2/HBoxContainer/MarginContainer/Label


func _ready():
	
	$mainAudio.play()
	
	round_timer.start(.1)
	
	astar_grid = AStarGrid2D.new()
	
	astar_grid.region = Rect2i(-153, -11, 565, 421)
	
	astar_grid.cell_size = Vector2(16, 16)
	
	astar_grid.update()
	
	spawn_pos_timer.start(30)
	
	big_duck_timer.start(20)
	
func get_path_arr(boid_postion, player_position):
	
	return astar_grid.get_id_path(boid_postion, player_position)
	
func create_duck(ins):
	# instantiate enemy
	
	spawn_timer.start(freq_spawning)
	
	spawn_is_ready = false
		
	boid_num = boid_num + 1
	
	ins.boid_num = boid_num
		
	var boid_position = spawn_pos[randi() % spawn_pos.size()]
			
	boid_position.x = boid_position.x + randi_range(-100, 100)
	
	boid_position.y = boid_position.y + randi_range(-100, 100)
			
	ins.position = boid_position
	
	add_child(ins)
	
	
	
func _physics_process(delta: float) -> void:
	
	# play quacking background noise
	if boid_num > 1 and can_quack_noise:
		$duckQuack.play()
		can_quack_noise = false
		$duckNoiseTimer.start(10)
	
	money_label.text = str(money)
	
	# display game over screen
	if player.health <= 0:
		Global.current_round = round
		get_tree().change_scene_to_packed(game_over_screen)
		
	# spawn entity
	if spawn_is_ready and boid_num < 350:
		if !special_round:
			var ins = new_duck.instantiate()
			create_duck(ins)
		
			if can_spawn_big_duck:
				var ins_bd = big_duck.instantiate()
				create_duck(ins_bd)
				big_duck_timer.start(45)
				can_spawn_big_duck = false
				
		else:
			
			var ins = mallard.instantiate()
			create_duck(ins)
			
		
	if round_is_done:
		
		change_round()
		round_is_done = false
		round_timer.start(round_time)
	
func duck_death_sound():
	$duckDeath.play()
	
func change_round():
	# keep track of round and round atrobutes
	
	round = round + 1
	
	special_round = false
	
	if round == 1:
		round_time = 30
		freq_spawning = 1.2
	
	elif round == 2:
		round_time = 30
		freq_spawning = .9
		
	elif round == 3:
		round_time = 40
		freq_spawning = .3
		
	elif round == 4:
		round_time = 40
		freq_spawning = 0.2
		
	elif round % 5 == 0:
		round_time = 40
		freq_spawning = .4
		special_round = true
	
	else:
		round_time = round_time + 5
		if freq_spawning > .025:
			freq_spawning = freq_spawning - .025
		
func _on_round_timer_timeout() -> void:
	# after time between rounds
	
	round_is_done = true
	
func _on_spawn_timer_timeout() -> void:
	# spawn cooldown
	
	spawn_is_ready = true

func _on_shop_area_body_entered(body: Node2D) -> void:
	# allows player acsess shop
	
	if body.has_method("player"):
		body.can_shop = true
		

func _on_shop_area_body_exited(body: Node2D) -> void:
	# stops player from acsessing shop
	
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
	# change current spawn positons to two random from set amount
	
	var index_1 = randi() % all_spawn_pos.size()
	
	var index_2 = index_1
	
	while index_2 == index_1:
		index_2 = randi() % all_spawn_pos.size()
	
	spawn_pos[0] = all_spawn_pos[index_1]
	
	spawn_pos[1] = all_spawn_pos[index_2]
	
	spawn_pos_timer.start(10)

func _on_duck_noise_timer_timeout() -> void:
	# after quack noise cooldown
	
	can_quack_noise = true

func _on_big_duck_timer_timeout() -> void:
	# after big duck spawn cooldown
	
	can_spawn_big_duck = true
