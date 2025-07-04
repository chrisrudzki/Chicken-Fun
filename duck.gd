extends Enemy

var boid_num

var attack_cooldown = true

var melee_dmg = 15
var splash = preload("res://splash.tscn")
var can_splash = true
var done_death = false

@onready var attack_cooldown_timer = $AttackCooldownTimer
@onready var attack_startup_timer = $AttackStartupTimer
@onready var splash_cooldown_timer = $SplashTimer

func boid():
	pass
	
func _ready():
	main_scene = get_parent()
	
	player = main_scene.get_node("Player")
	
	$AnimatedSprite2D.play("swim")
	
	health = 100
	
	move_speed = 1.8
	
func walk():
	$AnimatedSprite2D.play("walk")
	
func swim():
	$AnimatedSprite2D.play("swim")
	
func get_main_scene():
	return main_scene
	
func get_player():
	return player
	
	
func die():
	# entity dies
	
	$AnimatedSprite2D.play("death")
	
	$CollisionShape2D.disabled = true

	$HitBox/CollisionShape2D.disabled = true
	
func attack(player_in_range, attack_ready):
	# entity attacks player
	
	if player_in_range and attack_ready:
		
		player.damage_self(melee_dmg)
		#animate player hurt
		
			
func _physics_process(delta):
	
	
	# start death sequence
	if health <= 0:
		if !done_death:
			done_death = true
			main_scene.duck_death_sound()
		can_splash = false
		die()
		
	# attack player 
	if player_in_range and attack_cooldown:
		
		
		attack_cooldown = false
		
		attack_startup_timer.start(.4)
		
		attack_cooldown_timer.start(2)
		
		$AnimatedSprite2D.play("attack")
	
	velocity = calc_velo(neighbours, on_island, move_speed, position)
	
	move_and_slide()
	
	# spawn splash animations
	if !on_island and can_splash:
		can_splash = false
		splash_cooldown_timer.start(.4)
		
		var instance = splash.instantiate()
	
		instance.position = position
		main_scene.add_child.call_deferred(instance)
		
	velocity = Vector2.ZERO
	

func _on_attack_cooldown_timer_timeout() -> void:
	attack_cooldown = true
	

func _on_animated_sprite_2d_animation_finished() -> void:
	
	# delete entity
	if $AnimatedSprite2D.animation == "death":
		queue_free()
		main_scene.money = main_scene.money + 5
		main_scene.boid_num = main_scene.boid_num - 1
	
	else:
	# go back to move animation
		if on_island:
			$AnimatedSprite2D.play("walk")
		else:
			$AnimatedSprite2D.play("swim")


func _on_hit_box_body_entered(body: Node2D) -> void:
	
	# big rock projectile enter entity
	if body.has_method("rock"):
		
		hit_self(body.dmg)
		
	# small rock projectile enter entity
	if body.has_method("bullet"):
		
		hit_self(body.dmg)
		body.delete_timer.start(.02)
		
	# wall projectile enter entity
	if body.has_method("wall"):
		
		body.velocity = Vector2.ZERO
		hit_self(12)

	if body.has_method("player"):
		player_in_range = true
		
	if body.has_method("big_duck"):
		# kill entity if big duck charges into it
		
		if body.is_charging == true:
			hit_self(120)
		
	
func _on_hit_box_body_exited(body: Node2D) -> void:
	if body.has_method("player"):
		player_in_range = false
		
func _on_neighbour_area_body_entered(body: Node2D) -> void:
	if (body.has_method("boid") and body.boid_num != boid_num):
		neighbours.append(body)

func _on_neighbour_area_body_exited(body: Node2D) -> void:
	if body.has_method("boid") and body.boid_num != boid_num:
		neighbours.erase(body)

func _on_attack_startup_timer_timeout() -> void:
	# time after pre attack animation
	
	attack(player_in_range, true)


func _on_splash_timer_timeout() -> void:
	can_splash = true
