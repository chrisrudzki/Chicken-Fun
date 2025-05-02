extends CharacterBody2D

@export var move_speed : int = 1850

var starting_direction = Vector2(0,1)
var input_direction = starting_direction

signal updateHealth
signal updateLevel

@onready var roll_timer = $rollTimer
@onready var roll_cooldown_timer = $rollCooldownTimer

@onready var shoot_cooldown_SG_timer = $shootCooldownSG
@onready var shoot_cooldown_BG_timer = $shootCooldownBG
@onready var shoot_cooldown_WG_timer = $shootCooldownWG


@onready var regen_health_timer = $regenHeathTimer
@onready var regen_health_timer2 = $regenHeathTimer2

var prev_input_direction = starting_direction
@onready var main = get_tree().get_root().get_node("Main Scene")
var rock = preload("res://rock.tscn")

var bullet = preload("res://bullet.tscn")
var wall = preload("res://wall.tscn")

var wall_amount = 0

var health = 100
var maxHealth = 100
var area

var can_shoot_small_gun = true
var can_shoot_big_gun = true
var can_shoot_wall_gun = true

var shoot_cooldown_small_gun = true
var shoot_cool_amount_small_gun = .2

var shoot_cooldown_big_gun = true
var shoot_cool_amount_big_gun = .6

var shoot_cooldown_wall_gun = true
#var shoot_cool_amount_small_gun = .2


#var shoot_count = 0

var player_in_roll = false
var roll_cooldown = true
var roll_len = .1865
var roll_cooldown_amount = 2.8


var cur_gun = 1
# guns
# 1 = small gun 
# 2 = big gun
# 3 = wall


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
	
	
	
func shoot_big_gun():
	var scalar = 20
	
	print("HERE!!")
	
	var mouse_pos_global = get_global_mouse_position()
	var loc_mouse_pos = main.to_local(mouse_pos_global)
	
	var dir = position.direction_to(loc_mouse_pos)
	
	var spawn_point = position + (dir * scalar)
	
	var instance = rock.instantiate()
	
	instance.spawn_pos = spawn_point
	instance.spawn_rot = rotation
	instance.x = dir
	main.add_child.call_deferred(instance)
	
func shoot_small_gun():
	var scalar = 20
	
	print("HERE!!")
	
	var mouse_pos_global = get_global_mouse_position()
	var loc_mouse_pos = main.to_local(mouse_pos_global)
	
	var dir = position.direction_to(loc_mouse_pos)
	
	
	var spawn_point = position + (dir * scalar)
	
	var instance = bullet.instantiate()
	
	instance.spawn_pos = spawn_point
	instance.spawn_rot = rotation
	instance.x = dir
	main.add_child.call_deferred(instance)
	
	
func shoot_wall_gun():
	var scalar = 20
	
	print("HERE!!")
	
	var mouse_pos_global = get_global_mouse_position()
	var loc_mouse_pos = main.to_local(mouse_pos_global)
	
	var dir = position.direction_to(loc_mouse_pos)
	
	var ang = dir.angle()
	
	print("ang ", ang)
	#var ang_rad = deg_to_rad(ang)
	
	
	var spawn_point = position + (dir * scalar)
	
	var instance = wall.instantiate()
	
	wall_amount = wall_amount + 1
	
	instance.wall_num = wall_amount
	instance.loc_mouse_pos = loc_mouse_pos
	instance.spawn_pos = spawn_point
	instance.spawn_rot = ang
	instance.x = dir
	main.add_child.call_deferred(instance)
	

func _physics_process(_delta):
	
	#print("pos  ", position)
	
	#print("pos ", position)
	
	if is_regen_health and health <= 100:
		health = health + 1
		updateHealth.emit()
	
	
	var shoot_input = Input.get_action_strength("shoot")
	
	var small_gun_change_wep = Input.get_action_strength("small_gun_change_wep")
	var big_gun_change_wep = Input.get_action_strength("big_gun_change_wep")
	var wall_gun_change_wep = Input.get_action_strength("wall_gun_change_wep")
	
	if small_gun_change_wep == 1:
		cur_gun = 1
		
	elif big_gun_change_wep == 1:
		cur_gun = 2
		
	elif wall_gun_change_wep == 1:
		cur_gun = 3
	
	#if shoot_count > 2:
		#shoot_count = 0
	
	#shoot_count = shoot_count + 1
	#print(cur_gun)
	#!!!!
	if shoot_input == 1 and can_shoot_small_gun and cur_gun == 1:
		
		shoot_cooldown_SG_timer.start(.70)
		can_shoot_small_gun = false
		
		shoot_small_gun()
		await get_tree().create_timer(0.08).timeout
		shoot_small_gun()
		await get_tree().create_timer(0.08).timeout
		shoot_small_gun()
		
	if shoot_input == 1 and can_shoot_big_gun and cur_gun == 2:
		
		shoot_cooldown_BG_timer.start(1.2)
		can_shoot_big_gun = false
		
		shoot_big_gun()
		
	if shoot_input == 1 and can_shoot_wall_gun and cur_gun == 3:
		
		shoot_cooldown_WG_timer.start(.5)
		can_shoot_wall_gun = false
		
		shoot_wall_gun()
		
	
	
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
	
	#var player_attack = Input.get_action_strength("attack")
	
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
	
	
	
	#if player_attack == 1 and shoot_cooldown:
		#
		#for i in len(enemys_in_range):
			#enemys_in_range[i].damage_self(30)
		#
		#shoot_cooldown_timer.start(shoot_cooldown_amount)
		#shoot_cooldown = false
	

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



func _on_roll_cooldown_timer_timeout() -> void:
	roll_cooldown = true


func _on_shoot_SG_timer_timeout() -> void:
	can_shoot_small_gun = true


func _on_shoot_BG_cooldown_timeout() -> void:
	can_shoot_big_gun = true


func _on_shoot_WG_cooldown_timeout() -> void:
	can_shoot_wall_gun = true
