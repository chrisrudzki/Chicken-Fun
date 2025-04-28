extends Area2D
var player


func _ready() -> void:
	var main_scene = get_parent()
	player = main_scene.get_node("Player")
	

func _on_body_entered(body: Node2D) -> void:
	if body.has_method("boid") or body.has_method("player"):
		body.in_area(4)


func _on_body_exited(body: Node2D) -> void:
	pass
