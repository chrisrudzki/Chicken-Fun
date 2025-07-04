extends Enemy

var boid_num

var attack_cooldown = false
var melee_dmg = 90
var is_charging = false
@onready var charge_timer = $chargeTimer
var charge_velocity
var prev_velocity
var prev_rotation
var charge_rot

@onready var attack_cooldown_timer = $AttackCooldownTimer


func walk():
	$AnimatedSprite2D.play("walk")
	
func swim():
	$AnimatedSprite2D.play("swim")
	
func boid():
	#used for identification
	pass

func _ready():
	
	#timer for charge attack
	attack_cooldown_timer.start(10)
	on_island = false

	enemy_type = "big_duck"
	move_speed = .5
	main_scene = get_parent()
	player = main_scene.get_node("Player")
	
	$AnimatedSprite2D.play("walk")
	health = 1000
	
func get_main_scene():
	return main_scene
	
func get_player():
	return player
	
func attack(player_in_range, attack_ready):
	#takes time for wind up
	#takes time for attack cooldown
	
	if player_in_range and attack_ready:
		
		
		$AnimatedSprite2D.play("attack")
		is_charging = true
		
		#pauses enemy direction for charge attack
		charge_velocity = prev_velocity
		charge_rot = prev_rotation
		move_speed = move_speed * 40
		
		#duration of charge
		charge_timer.start(2)
		
		
func hit_self(dmg_amount):
	#self is damaged
	
	health = health - dmg_amount
	if $AnimatedSprite2D.animation != "death":
		$AnimatedSprite2D.play("hit")
	
func die():
	#self dies
	
	$AnimatedSprite2D.play("death")
	main_scene.boid_num = main_scene.boid_num -1
	main_scene.money = main_scene.money + 100
	$HitBox/CollisionShape2D.disabled = true
	
	
func _physics_process(delta):
	
	if health <= 0:
		die()
		
	if player_in_range and attack_cooldown:
		#self attacking player
		
		attack_cooldown = false
		
		attack_cooldown_timer.start(10)
		$AnimatedSprite2D.play("attackStartUp")
		
	print("move speed out", move_speed)
	
	velocity = calc_velo(neighbours, on_island, move_speed, position)
	
	if is_charging:
		
		#pauses enemy direction and rotation for charge attack
		velocity = charge_velocity * move_speed
		rotation = prev_rotation
	
	
	move_and_slide()
	prev_velocity = velocity
	prev_rotation = rotation
	
	velocity = Vector2.ZERO
	
func _on_hit_box_body_entered(body: Node2D) -> void:
	#if other entity enters self
	
	if body.has_method("rock"):
		
		hit_self(120)
		
	if body.has_method("bullet"):
		
		hit_self(body.dmg)
		body.delete_timer.start(.02)
		
		
	if body.has_method("wall"):
		
		hit_self(120)
		
	if body.has_method("player") and is_charging:
		#if self if charging, damage the player
		body.damage_self(80)
		


func _on_hit_box_body_exited(body: Node2D) -> void:
	
	if body.has_method("player"):
		player_in_range = false
		


func _on_attack_cooldown_timer_timeout() -> void:
	attack_cooldown = true
	

func _on_animated_sprite_2d_animation_finished() -> void:
	if $AnimatedSprite2D.animation == "death":
		queue_free()
		main_scene.money = main_scene.money + 5
		
	elif $AnimatedSprite2D.animation == "attackStartUp":
		attack(true, true)
		
	else:
		$AnimatedSprite2D.play("walk")
		
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.has_method("player"):
		player_in_range = true
	
func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.has_method("player"):
		player_in_range = false
		

func _on_charge_timer_timeout() -> void:
	#after self charge attack
	
	is_charging = false
	move_speed = .5
	$AnimatedSprite2D.play("walk")
