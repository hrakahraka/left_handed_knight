extends Area2D

signal touched

var player = null


func _ready() -> void:
	player = get_tree().get_nodes_in_group("player")[0]
	$AnimatedSprite2D.play()
	$AnimationPlayer.play("Float")


func _on_area_entered(area: Area2D) -> void:
	if player.HP_points < player.max_health:
		emit_signal("touched")
		queue_free()
