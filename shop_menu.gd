extends Control


@export var player: CharacterBody2D


func resume():
	get_tree().paused = false
	$AnimationPlayer.play_backwards("blur")
	
func pause():
	get_tree().paused = true
	$AnimationPlayer.play("blur")


func shop_menu():
	if  Input.is_action_just_pressed("shop_menu") and get_tree().paused == false and player.can_shop == true:
		pause()
	elif Input.is_action_just_pressed("shop_menu") and get_tree().paused == true:
		resume()
		
		
func _process(delta):
		shop_menu()


func _on_button_button_down() -> void:
	resume()


func _on_rock_gun_button_down() -> void:
	player.small_gun_upgrade()

func _on_boulder_button_down() -> void:
	player.big_gun_upgrade()

func _on_wall_gun_button_down() -> void:
	player.wall_gun_upgrade()
