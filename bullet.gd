extends CharacterBody2D


@export var speed = 380
@onready var delete_timer = $Timer

#var dir : float
var dmg
var spawn_pos : Vector2
var spawn_rot : float
var x

func bullet():
	pass

func _ready():
	position = spawn_pos
	rotation = spawn_rot
	
	#de-spawns bullet
	delete_timer.start(3)
	
func _physics_process(delta):
	
	if x != null:
		velocity = x * speed
	move_and_slide()
	


func _on_timer_timeout() -> void:
	queue_free()


func _on_delete_timer_timeout() -> void:
	queue_free()
