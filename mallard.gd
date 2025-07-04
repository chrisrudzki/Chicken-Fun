extends Enemy

var boid_num

var attack_cooldown = false

var melee_dmg = 40

var is_charging = false

var charge_velocity

var prev_velocity

var prev_rotation

var charge_rot

@onready var charge_timer = $chargeTimer

@onready var attack_cooldown_timer = $attackCooldownTimer

func walk():
	$AnimatedSprite2D.play("walk")
	
func swim():
	$AnimatedSprite2D.play("swim")
	
func boid():
	pass

func _ready():
	
	attack_cooldown_timer.start(4)
	
	on_island = false

	enemy_type = "mallard"
	
	move_speed = 1
	
	main_scene = get_parent()
	
	player = main_scene.get_node("Player")
	
	$AnimatedSprite2D.play("swim")
	
	health = 10
	
func get_main_scene():
	return main_scene
	
func get_player():
	return player
	
func attack(player_in_range, attack_ready):
	
	# entity has charge attack
	if player_in_range and attack_ready:
		
		$AnimatedSprite2D.play("attack")
		
		is_charging = true
		
		charge_velocity = prev_velocity
		
		charge_rot = prev_rotation
		
		move_speed = move_speed * 15
		
		charge_timer.start(1.7)
		
func hit_self(dmg_amount):
	health = health - dmg_amount
	
func die():
	# enemy death before deletion
	
	$AnimatedSprite2D.play("death")
	
	main_scene.boid_num = main_scene.boid_num -1
	
	main_scene.money = main_scene.money + 100
	
	$Area2D2/CollisionShape2D.disabled = true
	
	$CollisionShape2D.disabled = true
	
	
func _physics_process(delta):
	
	if health <= 0:
		die()
	
	# determines if enemy can attack
	if player_in_range and attack_cooldown:
		
		attack_cooldown = false
		
		attack_cooldown_timer.start(4)
		
		attack(true, true)
		
	
	velocity = calc_velo(neighbours, on_island, move_speed, position)

	# locks specifics when charging
	if is_charging:
		velocity = charge_velocity * move_speed
		rotation = prev_rotation
	
	move_and_slide()
	
	prev_velocity = velocity
	prev_rotation = rotation
	
	velocity = Vector2.ZERO


func _on_animated_sprite_2d_animation_finished() -> void:
	
	# delete entity 
	if $AnimatedSprite2D.animation == "death":
		
		queue_free()
		
		main_scene.money = main_scene.money + 5
		
	else:
		$AnimatedSprite2D.play("walk")
		


func _on_charge_timer_timeout() -> void:
	#charge ended
	
	is_charging = false
	
	move_speed = 1
	
	if on_island:
		$AnimatedSprite2D.play("walk")
	else:
		$AnimatedSprite2D.play("swim")



func _on_area_2d_body_entered(body: Node2D) -> void:
	
	if body.has_method("player"):
		
		player_in_range = true

func _on_area_2d_body_exited(body: Node2D) -> void:
	
	if body.has_method("player"):
		
		player_in_range = false


func _on_attack_cooldown_timer_timeout() -> void:
	attack_cooldown = true


func _on_area_2d_2_body_entered(body: Node2D) -> void:
	
	if body.has_method("rock"):
		# small rock projectile enter entity
		
		hit_self(body.dmg)
		
	if body.has_method("bullet"):
		# small rock projectile enter entity
		
		hit_self(body.dmg)
		
		body.delete_timer.start(.02)
		
		
	if body.has_method("wall"):
		# wall enters entity
		
		hit_self(body.dmg)
		
	if body.has_method("player") and is_charging:
		
		body.damage_self(40)
