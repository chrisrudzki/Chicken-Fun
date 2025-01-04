extends Area2D
var player


func _ready() -> void:
	var main_scene = get_parent()
	player = main_scene.get_node("Player")
	
#
#func _physics_process(delta: float) -> void:
	#pass
	#



func _on_body_entered(body: Node2D) -> void:
	#print("enterd")
	if body.has_method("boid") or body.has_method("player"):
		#print("yes")
		body.in_area(3)


func _on_body_exited(body: Node2D) -> void:
	pass # Replace with function body.
