extends CharacterBody2D


@export var speed = 190
@onready var timer = $Timer
@onready var stop_timer = $stop_timer

var spawn_pos : Vector2

var spawn_rot : float

var x

var loc_mouse_pos : Vector2

var wall_num : int

var dmg = 1000

var is_stopped = false

func wall():
	pass

# when the wall hits an object
func hitwall():
	velocity = velocity / 7
	stop_timer.start(.05)

func _ready():
	
	print(x)
	
	position = spawn_pos
	
	rotation = spawn_rot
	
	timer.start(25)
	
# 
func _physics_process(delta):
	
	velocity = x * speed
	
	# stop if wall has reached the mouse position
	if Vector2(2,2) > position - loc_mouse_pos and Vector2(-2,-2) < position - loc_mouse_pos:
		velocity = Vector2.ZERO
		
	if is_stopped:
		velocity = Vector2.ZERO
	
	move_and_slide()


func _on_timer_timeout() -> void:
	queue_free()


func _on_hitbox_body_entered(body: Node2D) -> void:
	
	if body.has_method("wall") and body.wall_num != wall_num:
		body.hitwall()
		
	if body.has_method("bullet"):
		body.velocity = Vector2.ZERO
		
	if body.has_method("boid"):
		is_stopped = true
		

func _on_stop_timer_timeout() -> void:
	is_stopped = true
