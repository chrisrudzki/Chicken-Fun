extends CharacterBody2D


@export var speed = 190
@onready var timer = $Timer
@onready var stop_timer = $stop_timer

#var dir : float
var spawn_pos : Vector2
var spawn_rot : float
var x
var loc_mouse_pos : Vector2
var wall_num : int

var is_stopped = false


func hitwall():
	#velocity = Vector2.ZERO
	velocity = velocity / 7
	stop_timer.start(.05)
	print("hitanother wall")
	
	
func wall():
	pass

func _ready():
	print(x)
	position = spawn_pos
	rotation = spawn_rot
	
	timer.start(25)
	
func _physics_process(delta):
	#print(x)
	
	
	
	if x != null and is_stopped == false:
		velocity = x * speed
	else:
		velocity = Vector2.ZERO
	#velocity = Vector2(0,-speed).rotated(dir)
		
	#print("position: ", position)
	#print("dest mouse position: ", loc_mouse_pos)	
		
	if Vector2(2,2) > position - loc_mouse_pos and Vector2(-2,-2) < position - loc_mouse_pos:
		velocity = Vector2.ZERO
		
	
	move_and_slide()


func _on_timer_timeout() -> void:
	queue_free()


func _on_hitbox_body_entered(body: Node2D) -> void:
	
	if body.has_method("wall") and body.wall_num != wall_num:
		body.hitwall()


func _on_hitbox_body_exited(body: Node2D) -> void:
	pass # Replace with function body.


func _on_stop_timer_timeout() -> void:
	print("got here")
	#velocity = Vector2.ZERO
	is_stopped = true
