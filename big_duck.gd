extends Enemy

var boid_num
var on_island = false

var attack_cooldown = true
var melee_dmg = 90


@onready var attack_cooldown_timer = $AttackCooldownTimer
@onready var attack_startup_timer = $AttackStartupTimer


func boid():
	pass

func _ready():
	enemy_type = "big_duck"
	move_speed = .02
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
		
		print("good attack! ", melee_dmg)
		player.damage_self(melee_dmg)
		#animate player hurt
		
	
func die():
	$AnimatedSprite2D.play("death")
	$CollisionShape2D.disabled = true
	main_scene.boid_num = main_scene.boid_num -1
	main_scene.money = main_scene.money + 100
	$HitBox/CollisionShape2D.disabled = true
	
func _physics_process(delta):
	
	if health <= 0:
		die()
		
	if player_in_range and attack_cooldown:
		attack_cooldown = false
		print("attacking here", player_in_range)
		attack_startup_timer.start(.4)
		attack_cooldown_timer.start(2)
		$AnimatedSprite2D.play("attack")
	
	velocity = calc_velo(neighbours, on_island, move_speed, position)
	move_and_slide()
	
	velocity = Vector2.ZERO
	

#func attack():
	#
	##player.damage_self(melee_dmg)
	#melee_cooldown = true
	#melee_cooldown_timer.wait_time = 2
	#melee_cooldown_timer.start()
	#
	#can_attack = false
	#attack_cooldown_timer.start(1.5)
	#$AnimatedSprite2D.play("attack")
	#


func _on_hit_box_body_entered(body: Node2D) -> void:
	if body.has_method("rock"):
		
		hit_self(120)
		
	if body.has_method("bullet"):
		
		hit_self(body.dmg)
		body.delete_timer.start(.02)
		
		#body.queue_free()
		
	if body.has_method("wall"):
		
		hit_self(120)

	if body.has_method("player"):
		
		player_in_range = true
	
	
	
	if body.has_method("player"):
		
		player_in_range = false
		

func _on_hit_box_body_exited(body: Node2D) -> void:
	
	if body.has_method("player"):
		
		player_in_range = false
		


func _on_attack_startup_timer_timeout() -> void:
	attack(player_in_range, true)

func _on_attack_cooldown_timer_timeout() -> void:
	attack_cooldown = true
	

func _on_animated_sprite_2d_animation_finished() -> void:
	
	if $AnimatedSprite2D.animation == "death":
		queue_free()
		main_scene.money = main_scene.money + 5
	else:
		$AnimatedSprite2D.play("walk")
