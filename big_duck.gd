extends Enemy




func boid():
	pass


func _ready():
	main_scene = get_parent()
	player = main_scene.get_node("Player")
	
	$AnimatedSprite2D.play("walk")
	health = 1000
	move_speed = .5
	
func get_main_scene():
	return main_scene
	
func get_player():
	return player

	
func die():
	$AnimatedSprite2D.play("death")
	$CollisionShape2D.disabled = true
	main_scene.boid_num = main_scene.boid_num -1
	main_scene.money = main_scene.money + 100
	$HitBox/CollisionShape2D.disabled = true
	
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
