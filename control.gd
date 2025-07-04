extends Control

func _ready():
	var bar = $HBoxContainer/MarginContainer/TextureProgressBar
	bar.custom_minimum_size = Vector2(150, 24)
