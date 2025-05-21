extends CharacterBody2D

var move_speed = 1.5

var neighbours = []

var boid_num
var player
var player_in_boid
var vel_slow = 2

var in_player_range = false

@onready var raycast1 = $RayCast2D
@onready var raycast2 = $RayCast2D2
@onready var raycast3 = $RayCast2D3
@onready var raycast4 = $RayCast2D4

@export var money_label : Label

@onready var timer = $Timer
@onready var timer2 = $Timer2
@onready var attack_cooldown_timer =$AttackCooldownTimer

@onready var knock_down_timer = $KnockdownTimer
@onready var bullet_timer = $BulletTimer



var money: int

var melee_dmg = 25

var on_island = false
var melee_cooldown = false
var is_attacking = false
var boid_stop = false
var knockback_timer = 0
var drag_coefficient = .01
var dir_to

var main_scene
var health = 100
#var roll_knockback
#var bullet_delete


var can_attack = true


#offset centre, adj movement, nearby velocity
var oc = Vector2.ZERO
var am = Vector2.ZERO
var nv = Vector2.ZERO

#am not used in inplamentation, prevents enemy groupings

var knockback = Vector2.ZERO


func all_raycasts():
	var casts = [raycast1, raycast2, raycast3, raycast4]
	return casts

func all_neighbours():
	return neighbours
	

func chicken_hit(dmg_amount):
	print("chicken hit")
	health = health - dmg_amount
	

func boid():
	pass

func get_player():
	if player != null:
		return player

	
func _ready():
	$AnimatedSprite2D.play("walk")
	main_scene = get_parent()
	

func damage_self(damage_amount):
	#if boid is damaged
	
	health = health - damage_amount
	print("health ", health)
	
	
func attack():
	can_attack = false
	attack_cooldown_timer.start(1.5)
	$AnimatedSprite2D.play("attack")
	
	
func _physics_process(_delta: float):
	if in_player_range and can_attack:
		attack()
	
	if health < 0:
		$AnimatedSprite2D.play("death")
		$CollisionShape2D.disabled = true
		main_scene.boid_num = main_scene.boid_num -1
		main_scene.money = main_scene.money + 5
		$Area2D/CollisionShape2D.disabled = true
		
		
	var player = main_scene.get_node("Player")
	
	if is_attacking and melee_cooldown == false:  
		player.damage_self(melee_dmg)
		melee_cooldown = true
		timer2.wait_time = 2
		timer2.start()
	
	
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
		
	
	move_and_slide()
	am = Vector2.ZERO
	velocity = Vector2.ZERO
	#nv = nv/4
	

	
func _on_area_2d_body_entered(body: Node2D) -> void:
	
	
	
			
	if (body.has_method("boid") and body.boid_num != boid_num):
		
		neighbours.append(body)
		
	
func _on_area_2d_body_exited(body: Node2D) -> void:
	
	
	if body.has_method("boid") and body.boid_num != boid_num:
		neighbours.erase(body)
		

#boid_player_coll

func _on_timer_timeout() -> void:
	pass


func _on_timer_2_timeout() -> void:
	melee_cooldown = false


		
func _on_area_2d_2_body_exited(body: Node2D) -> void:
	pass # Replace with function body.
	
	
func _on_knock_down_timer_timeout() -> void:
	pass # Replace with function body.



func _on_animated_sprite_2d_animation_finished() -> void:
	
	if $AnimatedSprite2D.animation == "death":
		queue_free()
	else:
		$AnimatedSprite2D.play("walk")


func _on_attack_cooldown_timer_timeout() -> void:
	can_attack = true
	
	
func _on_attack_collision_body_entered(body: Node2D) -> void:
	
	if body.has_method("rock"):
		
		chicken_hit(120)
		
	if body.has_method("bullet"):
		
		chicken_hit(35)
		body.delete_timer.start(.02)
		
		#body.queue_free()
		
	if body.has_method("wall"):
		
		chicken_hit(120)

	if body.has_method("player"):
		
		player_in_boid = true
		
		is_attacking = true
	
	

func _on_attack_collision_body_exited(body: Node2D) -> void:
	if body.has_method("player"):
		
		player_in_boid = false
		is_attacking = false
