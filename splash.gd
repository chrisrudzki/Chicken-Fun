extends CharacterBody2D
@onready var kill_timer = $Timer

var time_till = 1.6


func _ready():
	kill_timer.start(time_till)
	

func _physics_process(delta: float) -> void:
	# animates over time
	scale *= Vector2(1.012, 1.012)
	$Sprite2D.modulate.a = 0.65 

# delete entity
func _on_timer_timeout() -> void:
	queue_free()
