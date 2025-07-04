extends CanvasLayer


var round_num = 99

var level

@onready var lvl_output = $LevelOutput

func _ready():
	# update level
	
	lvl_output.text = "YOU REACHED LEVEL " + str(Global.current_round)

func _on_button_pressed() -> void:
	# restart game
	
	get_tree().change_scene_to_file("res://main_scene.tscn")
	
	
