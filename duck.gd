#extends Node2D
extends Enemy

var neighbours = []
var boid_num
var move_speed = 1.7
var on_island = false

func boid():
	pass
	
func _ready():
	$AnimatedSprite2D.play("walk")

func _physics_process(delta):
	
	velocity = calc_velo(neighbours, on_island, move_speed)
	move_and_slide()
	
	velocity = Vector2.ZERO
	

func _on_area_2d_body_entered(body: Node2D) -> void:
	if (body.has_method("boid") and body.boid_num != boid_num):
		neighbours.append(body)

func _on_area_2d_body_exited(body: Node2D) -> void:
	
	if body.has_method("boid") and body.boid_num != boid_num:
		neighbours.erase(body)
		
