extends CharacterBody2D

@export var move_speed : int = 1550

var starting_direction = Vector2(0,1)

var input_direction = Vector2(0,0)
signal updateHealth
signal updateLevel

@onready var roll_timer = $rollTimer
@onready var roll_cooldown_timer = $rollCooldownTimer

@onready var splash_cooldown_timer = $SplashTimer
@onready var shoot_cooldown_SG_timer = $shootCooldownSG
@onready var shoot_cooldown_BG_timer = $shootCooldownBG
@onready var shoot_cooldown_WG_timer = $shootCooldownWG

@onready var regen_health_timer = $regenHeathTimer
@onready var regen_health_timer2 = $regenHeathTimer2
@onready var animation_tree = $AnimationTree

@onready var state_machine = animation_tree.get("parameters/playback")

var prev_input_direction = starting_direction
@onready var main_scene = get_tree().get_root().get_node("Main Scene")
var rock = preload("res://rock.tscn")

var bullet = preload("res://bullet.tscn")
var wall = preload("res://wall.tscn")
var splash = preload("res://splash.tscn")
var feet_prints = preload("res://feet_prints.tscn")


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

var bullet_dmg = 35


var cur_gun = 1
# guns
# 1 = small gun 
# 2 = big gun
# 3 = wall

var is_regen_health = false

var can_shop = false

var is_idle
var is_walking

var on_island = true
var can_splash = true

func player():
	pass
	
func in_area(new_area):
	
	area = new_area
	
	
func damage_self(damage):
	
	regen_health_timer.start(1)
	health = health - damage
	$Sprite2D.modulate = Color(1, 0, 0) # make player red
	await get_tree().create_timer(0.4).timeout
	$Sprite2D.modulate = Color(1, 1, 1) # make player color normal
	updateHealth.emit()
	
func small_gun_upgrade():
	# keeps track of small gun level and upgrades gun
	
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
	# keeps track of big gun level and upgrades gun
	
	big_gun_lvl = big_gun_lvl + 1
	
	if big_gun_lvl == 1:
		shoot_cool_amount_big_gun = 2.5
	if big_gun_lvl == 2:
		shoot_cool_amount_big_gun = 1.5
	if big_gun_lvl == 3:
		shoot_cool_amount_big_gun = 1.0
	
func wall_gun_upgrade():
	# keeps track of wall gun level and upgrades gun
	
	wall_gun_lvl = wall_gun_lvl + 1
	
	if wall_gun_lvl == 1:
		shoot_cool_amount_wall_gun = 3
	if wall_gun_lvl == 2:
		shoot_cool_amount_wall_gun = 2
	if wall_gun_lvl == 3:
		shoot_cool_amount_wall_gun = 1
	
func det_cur_state():
	# determines walk or idle animation category
	
	if(velocity != Vector2.ZERO):
		state_machine.travel("walk")
	else:
		state_machine.travel("idle")
	
func shoot_small_gun():
	# shoots small bullet baised on player mouse position
	
	var scalar = 20
	
	var mouse_pos_global = get_global_mouse_position()
	
	var loc_mouse_pos = main_scene.to_local(mouse_pos_global)
	
	var dir = position.direction_to(loc_mouse_pos)
	
	var spawn_point = position + (dir * scalar)
	
	var instance = bullet.instantiate()
	
	instance.dmg = bullet_dmg
	instance.speed = bullet_speed
	instance.spawn_pos = spawn_point
	instance.spawn_rot = rotation
	instance.x = dir
	main_scene.add_child.call_deferred(instance)
	
func shoot_big_gun():
	# shoots big bullet baised on player mouse position
	
	var scalar = 20
	
	var mouse_pos_global = get_global_mouse_position()
	
	var loc_mouse_pos = main_scene.to_local(mouse_pos_global)
	
	var dir = position.direction_to(loc_mouse_pos)
	
	var spawn_point = position + (dir * scalar)
	
	var instance = rock.instantiate()
	
	instance.spawn_pos = spawn_point
	instance.spawn_rot = rotation
	instance.x = dir
	main_scene.add_child.call_deferred(instance)

func shoot_wall_gun():
	# shoots small bullet baised on player mouse position
	
	var scalar = 20
	
	var mouse_pos_global = get_global_mouse_position()
	
	var loc_mouse_pos = main_scene.to_local(mouse_pos_global)
	
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
	main_scene.add_child.call_deferred(instance)
	
	
func _ready():
	update_animation_parameters(starting_direction)
	
func _physics_process(_delta):
	
	if is_regen_health and health <= 100:
		# heal player after time with low health
		
		health = health + 1
		updateHealth.emit()
	
	
	# get player input
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
	
	if shoot_input == 1 and can_shoot_small_gun and cur_gun == 1:
		# shoot small gun
		# check cooldown, current equipt gun
		# play pre-shoot animation
		
		shoot_cooldown_SG_timer.start(.70)
		can_shoot_small_gun = false
		
		shoot_small_gun()
		animation_tree["parameters/conditions/swing"] = true
		for i in range(shoot_small_gun_amount-1):
			await get_tree().create_timer(0.08).timeout
			shoot_small_gun()
		
		
	elif shoot_input == 1 and can_shoot_big_gun and cur_gun == 2:
		# shoot big gun
		# check cooldown, current equipt gun
		# play pre-shoot animation
		
		shoot_cooldown_BG_timer.start(shoot_cool_amount_big_gun)
		can_shoot_big_gun = false
		animation_tree["parameters/conditions/swing"] = true
		shoot_big_gun()
		
	elif shoot_input == 1 and can_shoot_wall_gun and cur_gun == 3:
		# shoot wall gun
		# check cooldown, current equipt gun
		# play pre-shoot animation
		
		shoot_cooldown_WG_timer.start(shoot_cool_amount_wall_gun)
		can_shoot_wall_gun = false
		animation_tree["parameters/conditions/swing"] = true
		shoot_wall_gun()
		
	else:
		animation_tree["parameters/conditions/swing"] = false
	
	
	input_direction = Vector2(
		# get player walk input

			Input.get_action_strength("right") - Input.get_action_strength("left"),
			Input.get_action_strength("down") - Input.get_action_strength("up")
		)
		
	update_animation_parameters(input_direction)
	
	if input_direction != Vector2.ZERO:
		prev_input_direction = input_direction
		

	if velocity != Vector2.ZERO:
		
		if !on_island and can_splash:
			# play splash animations
			
			can_splash = false
			splash_cooldown_timer.start(.4)
		
			var instance = splash.instantiate()
			instance.scale *= 2
			instance.position = position
			main_scene.add_child.call_deferred(instance)
		
		elif on_island and can_splash:
			# play foot print animations
			
			can_splash = false
			splash_cooldown_timer.start(.09)
		
			var instance = feet_prints.instantiate()
			instance.position = position
			instance.rotation = velocity.angle()
			main_scene.add_child.call_deferred(instance)
	
	
	input_direction = input_direction.normalized()

	velocity = input_direction * move_speed * _delta
	
	move_and_slide()
	
	det_cur_state()
	
	

func update_animation_parameters(move_input : Vector2):
	# set player animations
	
	if(move_input != Vector2.ZERO):
		# set move direction of animation catagories
	
		animation_tree.set("parameters/idle/blend_position", move_input)
		animation_tree.set("parameters/walk/blend_position", move_input)
		animation_tree.set("parameters/attack/blend_position", move_input)
		
		animation_tree["parameters/conditions/is_idle"] = false
		animation_tree["parameters/conditions/is_walking"] = true
		
	else:
		#idle if player not moving
		
		animation_tree["parameters/conditions/is_idle"] = true
		animation_tree["parameters/conditions/is_walking"] = false
	


func _on_regen_heath_timer_timeout() -> void:
	# after time damaged, re-gen health
	
	is_regen_health = true
	regen_health_timer2.start(.7)
	

func _on_regen_heath_timer_2_timeout() -> void:
	# after health is re-gen
	
	is_regen_health = false


func _on_shoot_SG_timer_timeout() -> void:
	# small gun cooldown timer
	
	can_shoot_small_gun = true

func _on_shoot_BG_cooldown_timeout() -> void:
	# big gun cooldown timer
	
	can_shoot_big_gun = true

func _on_shoot_WG_cooldown_timeout() -> void:
	# wall gun cooldown timer
	
	can_shoot_wall_gun = true

func _on_splash_timer_timeout() -> void:
	# splash animation cooldown timer
	
	can_splash = true
