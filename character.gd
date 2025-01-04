extends CharacterBody2D

@export var move_speed : int = 10000

var starting_direction = Vector2(0,1)
var input_direction = starting_direction

signal updateHealth


@onready var timer = $Timer
var prev_input_direction = starting_direction
var player_rolling = false

var health = 100
var maxHealth = 100
var area

func player():
	pass
	
	
func in_area(new_area):
	
	print("NEW AREA")
	area = new_area
	
	
func get_hit(x):
	
	health = health - x
	updateHealth.emit()
	#print("HEALTH: ", health)
	
func _physics_process(_delta):
	
	
	print("player area ", area)
	
	if !player_rolling:
		input_direction = Vector2(
			Input.get_action_strength("right") - Input.get_action_strength("left"),
			Input.get_action_strength("down") - Input.get_action_strength("up")
		)
	
	
	
	if input_direction != Vector2.ZERO:
		prev_input_direction = input_direction
		
	#print(position)
	
	var player_roll = Input.get_action_strength("space")
	
	if player_roll:
		player_rolling = true
		move_speed = 32000
		
		timer.wait_time = .113
		timer.start()
		
	if player_rolling == true:
		input_direction = prev_input_direction
	
	
	input_direction = input_direction.normalized()
	
	#print("c vel", input_direction * move_speed * _delta)
	
	velocity = input_direction * move_speed * _delta
	
	
	move_and_slide()
	
	
func _on_timer_timeout() -> void:
	move_speed = 10000
	player_rolling = false
	velocity = Vector2.ZERO # Replace with function body.
