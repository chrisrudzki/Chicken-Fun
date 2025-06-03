extends CharacterBody2D

@onready var kill_timer = $Timer

var time_till = 1


func _ready():
	kill_timer.start(time_till)
	


func _physics_process(delta: float) -> void:
	
	$Sprite2D.modulate.a = 0.80


func _on_timer_timeout() -> void:
	queue_free()
