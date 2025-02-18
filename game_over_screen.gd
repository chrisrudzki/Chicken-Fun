extends CanvasLayer


var round_num = 99
var level
@onready var lvl_output = $LevelOutput
#@export var player: CharacterBody2D

func _ready():
	lvl_output.text = "YOU REACHED LEVEL " + str(Global.current_round)

func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://main_scene.tscn")
	
	
