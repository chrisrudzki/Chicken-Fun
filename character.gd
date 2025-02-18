extends CharacterBody2D

@export var move_speed : int = 10000

var starting_direction = Vector2(0,1)
var input_direction = starting_direction

signal updateHealth
signal updateLevel

@onready var roll_timer = $rollTimer
@onready var roll_cooldown_timer = $rollCooldownTimer
@onready var shoot_cooldown_timer = $shootTimer
@onready var regen_health_timer = $regenHeathTimer
@onready var regen_health_timer2 = $regenHeathTimer2

var prev_input_direction = starting_direction
@onready var main = get_tree().get_root().get_node("Main Scene")
var rock = preload("res://rock.tscn")


var health = 100
var maxHealth = 100
var area

var can_shoot = true
var shoot_cooldown = true
var shoot_cooldown_amount = 2
var shoot_count = 0

var player_in_roll = false
var roll_cooldown = true
var roll_len = .1865
var roll_cooldown_amount = 2.8

var enemys_in_range = []
var is_regen_health = false

func player():
	pass
	
	
func in_area(new_area):
	
	area = new_area
	
	
func damage_self(x):
	
	regen_health_timer.start(1)
	health = health - x
	updateHealth.emit()
	
	
	
func shoot():
	var scalar = 20.5
	
	var dis_between = ((get_global_mouse_position().x - position.x) ** 2 + (get_global_mouse_position().y - position.y) ** 2) ** .5
	var scaled_x = (scalar * ( get_global_mouse_position().x - position.x)) / dis_between
	var scaled_y = (scalar * ( get_global_mouse_position().y - position.y)) / dis_between
	
	var scaled_dir = position + Vector2(scaled_x, scaled_y)
	
	var instance = rock.instantiate()
	instance.dir = rotation
	instance.spawn_pos = scaled_dir 
	instance.spawn_rot = rotation
	instance.x = position.direction_to(get_global_mouse_position())
	main.add_child.call_deferred(instance)
	

func _physics_process(_delta):
	
	print("pos  ", position)
	
	if is_regen_health and health <= 100:
		health = health + 1
		updateHealth.emit()
		
	
	var shoot_input = Input.get_action_strength("shoot")
	
	
	if shoot_count > 2:
		shoot_count = 0
	
	shoot_count = shoot_count + 1
	
	
	if shoot_input == 1 and can_shoot:
		
		shoot_cooldown_timer.start(5)
		can_shoot = false
		
		shoot()
	
	
	if health < 0:
		#death animation 
		pass
		
		
	if velocity != Vector2.ZERO:
		rotation = lerp_angle(rotation, velocity.angle(), .4)
	
	
	
	if !player_in_roll:
		input_direction = Vector2(
			Input.get_action_strength("right") - Input.get_action_strength("left"),
			Input.get_action_strength("down") - Input.get_action_strength("up")
		)
	
	if input_direction != Vector2.ZERO:
		prev_input_direction = input_direction
		
	
	var player_roll = Input.get_action_strength("space")
	
	var player_attack = Input.get_action_strength("attack")
	
	if player_roll and roll_cooldown:
		
		
		for i in len(enemys_in_range):
			
			enemys_in_range[i].damage_self(30)
			
			
			
		player_in_roll = true
		move_speed = 27000
		
		
		roll_timer.start(roll_len)
		roll_cooldown_timer.start(roll_cooldown_amount)
		roll_cooldown = false
		
		
		
	if player_in_roll == true:
		input_direction = prev_input_direction
	
	
	input_direction = input_direction.normalized()
	
	
	
	if player_attack == 1 and shoot_cooldown:
		
		for i in len(enemys_in_range):
			enemys_in_range[i].damage_self(30)
		
		shoot_cooldown_timer.start(shoot_cooldown_amount)
		shoot_cooldown = false
		

	velocity = input_direction * move_speed * _delta
	
	
	move_and_slide()
	

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.has_method("boid"):
		
		damage_self(10)
		enemys_in_range.append(body)
		
	
func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.has_method("boid"):
		
		enemys_in_range.erase(body)
		




func _on_regen_heath_timer_timeout() -> void:
	is_regen_health = true
	regen_health_timer2.start(.7)
	

func _on_regen_heath_timer_2_timeout() -> void:
	is_regen_health = false


func _on_roll_timer_timeout() -> void:
	move_speed = 10000
	player_in_roll = false


func _on_shoot_timer_timeout() -> void:
	can_shoot = true


func _on_roll_cooldown_timer_timeout() -> void:
	roll_cooldown = true
