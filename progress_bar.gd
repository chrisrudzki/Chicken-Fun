extends TextureProgressBar


@export var player: CharacterBody2D


func update():
	value = player.health * 100 / player.maxHealth


func _on_player_update_health() -> void:
	update()
