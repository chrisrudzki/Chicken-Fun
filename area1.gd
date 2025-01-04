extends StaticBody2D


var player


func _ready() -> void:
	var main_scene = get_parent()
	player = main_scene.get_node("Player")
	

func _physics_process(delta: float) -> void:
	pass
	



func _on_area_2d_area_shape_entered(body: Node2D) -> void:
	print("enterd")
	if body.has_method("boid"):
		print("yes")
		body.in_area(1)
	
	
	
	#may not be needed
func _on_area_2d_area_shape_exited(body: CharacterBody2D) -> void:
	pass # Replace with function body.
