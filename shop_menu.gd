extends Control


@export var player: CharacterBody2D
var small_gun_lvl = 1
var big_gun_lvl = 1
var wall_gun_lvl = 1

var can_rock_button = true
var can_boulder_button = true
var can_wall_button = true

var rock_lvl_2_cost = 200
var rock_lvl_3_cost = 1200
var rock_lvl_4_cost = 2000
var rock_lvl_5_cost = 3000


var boulder_lvl_2_cost = 200
var boulder_lvl_3_cost = 1200
var boulder_lvl_4_cost = 2000

var wall_lvl_2_cost = 500
var wall_lvl_3_cost = 1500
var wall_lvl_4_cost = 2000

var main_scene

func _ready():
	main_scene = get_tree().get_current_scene()


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
		
func small_gun_upgrade(money):
	var did_lvl
	
	if (money >= rock_lvl_2_cost and small_gun_lvl == 1):
		did_lvl = true
	
		$PanelContainer/HBoxContainer/VBoxContainer/rock_gun.text = "Rock 2"
		$PanelContainer/HBoxContainer/VBoxContainer2/Label1.text = "$ " + str(rock_lvl_2_cost)
		main_scene.money = main_scene.money - rock_lvl_2_cost
		
	elif (money >= rock_lvl_3_cost and small_gun_lvl == 2):
		did_lvl = true
		
		$PanelContainer/HBoxContainer/VBoxContainer/rock_gun.text = "Rock 3"
		$PanelContainer/HBoxContainer/VBoxContainer2/Label1.text = "$ " + str(rock_lvl_3_cost)
		main_scene.money = main_scene.money - rock_lvl_3_cost
		
	elif (money >= rock_lvl_4_cost and small_gun_lvl == 3):
		did_lvl = true
		
		$PanelContainer/HBoxContainer/VBoxContainer/rock_gun.text = "Rock 4"
		$PanelContainer/HBoxContainer/VBoxContainer2/Label1.text = "$ " + str(rock_lvl_4_cost)
		main_scene.money = main_scene.money - rock_lvl_4_cost
		
	elif (money >= rock_lvl_5_cost and small_gun_lvl == 4):
		did_lvl = true
		
		
		$PanelContainer/HBoxContainer/VBoxContainer/rock_gun.text = "Rock 5"
		$PanelContainer/HBoxContainer/VBoxContainer2/Label1.text = "disc here "
		main_scene.money = main_scene.money - rock_lvl_5_cost
		
	elif small_gun_lvl == 6:
		$PanelContainer/HBoxContainer/VBoxContainer/rock_gun.text = " "
		$PanelContainer/HBoxContainer/VBoxContainer2/Label1.text = "Full upgrades"
		can_rock_button = false
		
		
	
	if did_lvl:
		player.small_gun_upgrade()
		small_gun_lvl += 1
		resume()
	
	
	
func big_gun_upgrade(money):
	var did_lvl = false
	
	if (money >= boulder_lvl_2_cost and big_gun_lvl == 1):
		did_lvl = true
		
		$PanelContainer/HBoxContainer/VBoxContainer/boulder.text = "Boulder 2"
		$PanelContainer/HBoxContainer/VBoxContainer2/Label2.text = "disc here "
		main_scene.money = main_scene.money - boulder_lvl_2_cost
		resume()
		
	elif (money >= boulder_lvl_3_cost and big_gun_lvl == 2):
		did_lvl = true
		
		$PanelContainer/HBoxContainer/VBoxContainer/boulder.text = "Boulder 3"
		$PanelContainer/HBoxContainer/VBoxContainer2/Label2.text = "$ " + str(boulder_lvl_3_cost)
		main_scene.money = main_scene.money - boulder_lvl_3_cost
		
	elif (money >= boulder_lvl_4_cost and big_gun_lvl == 3):
		did_lvl = true
		
		$PanelContainer/HBoxContainer/VBoxContainer/boulder.text = "Boulder 4"
		$PanelContainer/HBoxContainer/VBoxContainer2/Label2.text = "$ " + str(boulder_lvl_4_cost)
		main_scene.money = main_scene.money - boulder_lvl_4_cost
	
	elif big_gun_lvl == 4:
		
		$PanelContainer/HBoxContainer/VBoxContainer/boulder.text = " "
		$PanelContainer/HBoxContainer/VBoxContainer2/Label2.text = " Full upgrades "
	
	
	if did_lvl:
		player.big_gun_upgrade()
		big_gun_lvl += 1
		resume()
	
	
func wall_gun_upgrade(money):
	
	var did_lvl
	
	if (money >= wall_lvl_2_cost and wall_gun_lvl == 1):
		did_lvl = true
		$PanelContainer/HBoxContainer/VBoxContainer/wall_gun.text = "Wall 2"
		$PanelContainer/HBoxContainer/VBoxContainer2/Label3.text = "$ " + str(wall_lvl_2_cost)
		main_scene.money = main_scene.money - wall_lvl_2_cost
		
		
	elif (money >= wall_lvl_3_cost and wall_gun_lvl == 2):
		did_lvl = true
		$PanelContainer/HBoxContainer/VBoxContainer/wall_gun.text = "Wall 3"
		$PanelContainer/HBoxContainer/VBoxContainer2/Label3.text = "$ " + str(wall_lvl_3_cost)
		main_scene.money = main_scene.money - wall_lvl_3_cost
		
		
	elif (money >= wall_lvl_4_cost and wall_gun_lvl == 3):
		did_lvl = true
		$PanelContainer/HBoxContainer/VBoxContainer/wall_gun.text = "Wall 4"
		$PanelContainer/HBoxContainer/VBoxContainer2/Label3.text = "$ " + str(wall_lvl_4_cost)
		main_scene.money = main_scene.money - wall_lvl_4_cost
		
	
	elif wall_gun_lvl == 4:
		$PanelContainer/HBoxContainer/VBoxContainer/wall_gun.text = " "
		$PanelContainer/HBoxContainer/VBoxContainer2/Label3.text = "Full upgrades"
	
	
	if did_lvl:
		player.wall_gun_upgrade()
		wall_gun_lvl += 1
		resume()
	
	
func _on_rock_gun_button_down() -> void:
	small_gun_upgrade(main_scene.money)
	

func _on_boulder_button_down() -> void:
	big_gun_upgrade(main_scene.money)
	

func _on_wall_gun_button_down() -> void:
	wall_gun_upgrade(main_scene.money)
