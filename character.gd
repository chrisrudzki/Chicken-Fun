extends CharacterBody2D

@export var move_speed : int = 1550

var starting_direction = Vector2(0,1)
#var input_direction = starting_direction

var input_direction = Vector2(0,0)
signal updateHealth
signal updateLevel

@onready var roll_timer = $rollTimer
@onready var roll_cooldown_timer = $rollCooldownTimer

@onready var shoot_cooldown_SG_timer = $shootCooldownSG
@onready var shoot_cooldown_BG_timer = $shootCooldownBG
@onready var shoot_cooldown_WG_timer = $shootCooldownWG

@onready var regen_health_timer = $regenHeathTimer
@onready var regen_health_timer2 = $regenHeathTimer2
@onready var animation_tree = $AnimationTree

@onready var state_machine = animation_tree.get("parameters/playback")

var prev_input_direction = starting_direction
@onready var main = get_tree().get_root().get_node("Main Scene")
var rock = preload("res://rock.tscn")

var bullet = preload("res://bullet.tscn")
var wall = preload("res://wall.tscn")

var wall_amount = 0

var health = 100
var maxHealth = 100
var area

var small_gun_lvl = 0
var big_gun_lvl = 0
var wall_gun_lvl = 0

var bullet_speed = 360

var can_shoot_small_gun = true
var can_shoot_big_gun = true
var can_shoot_wall_gun = true

var shoot_cooldown_small_gun = true
var shoot_cool_amount_small_gun = .2

var shoot_cooldown_big_gun = true
var shoot_cool_amount_big_gun = 3.0

var shoot_cool_amount_wall_gun = 4
var shoot_cooldown_wall_gun = true
var shoot_small_gun_amount = 2

#var shoot_count = 0

var player_in_roll = false
var roll_cooldown = true
var roll_len = .1865
var roll_cooldown_amount = 2.8

var bullet_dmg = 35


var cur_gun = 1
# guns
# 1 = small gun 
# 2 = big gun
# 3 = wall


var enemys_in_range = []
var is_regen_health = false

var can_shop = false

var is_idle
var is_walking


#parameters/idle/blend_position
func player():
	pass
	
	
func in_area(new_area):
	
	area = new_area
	
	
func damage_self(x):
	
	regen_health_timer.start(1)
	health = health - x
	updateHealth.emit()
	
	
	
func small_gun_upgrade():
	small_gun_lvl = small_gun_lvl + 1
	
	if small_gun_lvl == 1:
		bullet_speed = 430
		shoot_small_gun_amount = 3
		
	elif small_gun_lvl == 2:
		bullet_speed = 550
		bullet_dmg = 55
	
	if small_gun_lvl == 3:
		shoot_small_gun_amount = 4
		
	elif small_gun_lvl == 5:
		bullet_dmg = 1020
	
func big_gun_upgrade():
	big_gun_lvl = big_gun_lvl + 1
	
	if big_gun_lvl == 1:
		shoot_cool_amount_big_gun = 2.5
	if big_gun_lvl == 2:
		shoot_cool_amount_big_gun = 1.5
	if big_gun_lvl == 3:
		shoot_cool_amount_big_gun = 1.0
	
func wall_gun_upgrade():
	wall_gun_lvl = wall_gun_lvl + 1
	
	if wall_gun_lvl == 1:
		shoot_cool_amount_wall_gun = 3
	if wall_gun_lvl == 2:
		shoot_cool_amount_wall_gun = 2
	if wall_gun_lvl == 3:
		shoot_cool_amount_wall_gun = 1
	
func det_cur_state():
	if(velocity != Vector2.ZERO):
		state_machine.travel("walk")
	else:
		state_machine.travel("idle")
	
func shoot_small_gun():
	var scalar = 20
	
	var mouse_pos_global = get_global_mouse_position()
	var loc_mouse_pos = main.to_local(mouse_pos_global)
	
	var dir = position.direction_to(loc_mouse_pos)
	
	var spawn_point = position + (dir * scalar)
	
	var instance = bullet.instantiate()
	
	instance.dmg = bullet_dmg
	instance.speed = bullet_speed
	instance.spawn_pos = spawn_point
	instance.spawn_rot = rotation
	instance.x = dir
	main.add_child.call_deferred(instance)
	
func shoot_big_gun():
	var scalar = 20
	
	
	var mouse_pos_global = get_global_mouse_position()
	var loc_mouse_pos = main.to_local(mouse_pos_global)
	
	var dir = position.direction_to(loc_mouse_pos)
	
	var spawn_point = position + (dir * scalar)
	
	var instance = rock.instantiate()
	
	instance.spawn_pos = spawn_point
	instance.spawn_rot = rotation
	instance.x = dir
	main.add_child.call_deferred(instance)
	

	
func shoot_wall_gun():
	var scalar = 20
	
	
	var mouse_pos_global = get_global_mouse_position()
	var loc_mouse_pos = main.to_local(mouse_pos_global)
	
	var dir = position.direction_to(loc_mouse_pos)
	
	var ang = dir.angle()
	
	var spawn_point = position + (dir * scalar)
	var instance = wall.instantiate()
	
	wall_amount = wall_amount + 1
	instance.wall_num = wall_amount
	instance.loc_mouse_pos = loc_mouse_pos
	instance.spawn_pos = spawn_point
	instance.spawn_rot = ang
	instance.x = dir
	main.add_child.call_deferred(instance)
	
	
func _ready():
	update_animation_parameters(starting_direction)

	$AnimatedSprite2D.play("walk")

func _physics_process(_delta):
	
	#print("pos  ", position)
	
	print("ani tree", $AnimationTree.get("parameters/playback"))
	
	print("health ", health)
	
	if is_regen_health and health <= 100:
		health = health + 1
		updateHealth.emit()
	
	
	var shoot_input = Input.get_action_strength("shoot")
	
	var small_gun_change_wep = Input.get_action_strength("small_gun_change_wep")
	var big_gun_change_wep = Input.get_action_strength("big_gun_change_wep")
	var wall_gun_change_wep = Input.get_action_strength("wall_gun_change_wep")
	
	#int(shoot_input)
	
	
	
	
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
		animation_tree["parameters/conditions/swing"] = true
		for i in range(shoot_small_gun_amount-1):
			await get_tree().create_timer(0.08).timeout
			shoot_small_gun()
		
		
	elif shoot_input == 1 and can_shoot_big_gun and cur_gun == 2:
		
		shoot_cooldown_BG_timer.start(shoot_cool_amount_big_gun)
		can_shoot_big_gun = false
		animation_tree["parameters/conditions/swing"] = true
		shoot_big_gun()
		
	elif shoot_input == 1 and can_shoot_wall_gun and cur_gun == 3:
		
		shoot_cooldown_WG_timer.start(shoot_cool_amount_wall_gun)
		can_shoot_wall_gun = false
		animation_tree["parameters/conditions/swing"] = true
		shoot_wall_gun()
		
	else:
		animation_tree["parameters/conditions/swing"] = false
		#gun_not_cool = true
		#
	#if int(shoot_input) == 1:
		#animation_tree["parameters/conditions/swing"] = true
	#else:
		#animation_tree["parameters/conditions/swing"] = false
	#
	
	if health < 0:
		#death animation 
		pass
		
		
	#if velocity != Vector2.ZERO:
		#rotation = lerp_angle(rotation, velocity.angle(), .4)
	#

	#if !player_in_roll:
		#input_direction = Vector2(
			#Input.get_action_strength("right") - Input.get_action_strength("left"),
			#Input.get_action_strength("down") - Input.get_action_strength("up")
		#)
		
	input_direction = Vector2(
			Input.get_action_strength("right") - Input.get_action_strength("left"),
			Input.get_action_strength("down") - Input.get_action_strength("up")
		)
		
	update_animation_parameters(input_direction)
	
	
	#if velocity == Vector2.ZERO:
		#$AnimatedSprite2D.play("idle")
	#else:
		#$AnimatedSprite2D.play("walk")
	
	if input_direction != Vector2.ZERO:
		prev_input_direction = input_direction
		
	#melee_cooldown
	#var player_roll = Input.get_action_strength("space")
	
	#var player_attack = Input.get_action_strength("attack")
	
	#if player_roll and roll_cooldown:
		
		#for i in len(enemys_in_range):
			#
			#enemys_in_range[i].damage_self(30)
			#
			
		#player_in_roll = true
		#move_speed = 27000
		#
		#
		#roll_timer.start(roll_len)
		#roll_cooldown_timer.start(roll_cooldown_amount)
		#roll_cooldown = false
		#
		#
	#if player_in_roll == true:
		#input_direction = prev_input_direction
	#
	
	#input_direction = input_direction.normalized()  !!!
	
	#damage_self
	
	input_direction = input_direction.normalized()

	velocity = input_direction * move_speed * _delta
	
#rotate
	print("in dir", input_direction)
	move_and_slide()
	
	det_cur_state()
	#print("herp 1", $AnimationTree.get("parameters/blend_amount"))
	
	

func update_animation_parameters(move_input : Vector2):
	
	if(move_input != Vector2.ZERO):
		animation_tree.set("parameters/idle/blend_position", move_input)
		animation_tree.set("parameters/walk/blend_position", move_input)
		animation_tree.set("parameters/attack/blend_position", move_input)
		
		animation_tree["parameters/conditions/is_idle"] = false
		animation_tree["parameters/conditions/is_walking"] = true
		
	else:
		animation_tree["parameters/conditions/is_idle"] = true
		animation_tree["parameters/conditions/is_walking"] = false
	
		#print("herp 2", state_machine.blend_position)
		
		
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.has_method("boid") and body.has_method("duck"):
		#if body.can_attack == true:
			#damage_self(10)
			#body.attack()
			#enemys_in_range.append(body)
			#body.in_player_range = true
		#body.in_player_range = true
		enemys_in_range.append(body)
	
func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.has_method("boid"):
		enemys_in_range.erase(body)
		#body.in_player_range = false
		

func _on_regen_heath_timer_timeout() -> void:
	is_regen_health = true
	regen_health_timer2.start(.7)
	

func _on_regen_heath_timer_2_timeout() -> void:
	is_regen_health = false


#func _on_roll_timer_timeout() -> void:
	#move_speed = 10000
	#player_in_roll = false
#
#func _on_roll_cooldown_timer_timeout() -> void:
	#roll_cooldown = true


func _on_shoot_SG_timer_timeout() -> void:
	can_shoot_small_gun = true


func _on_shoot_BG_cooldown_timeout() -> void:
	can_shoot_big_gun = true


func _on_shoot_WG_cooldown_timeout() -> void:
	can_shoot_wall_gun = true
