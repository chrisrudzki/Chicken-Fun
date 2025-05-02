extends CharacterBody2D


@export var speed = 90
@onready var timer = $Timer


var dir : float
var spawn_pos : Vector2
var spawn_rot : float
var x


func rock():
	pass

func _ready():
	
	position = spawn_pos
	rotation = spawn_rot
	
	timer.start(8)
	
func _physics_process(delta):

	if x != null:
		velocity = x * speed
	#velocity = Vector2(0,-speed).rotated(dir)
	
	move_and_slide()
	


func _on_timer_timeout() -> void:
	queue_free()
