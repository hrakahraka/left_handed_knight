extends Area2D

signal touched

var player = null
var follow = false


func _ready() -> void:
	player = get_tree().get_nodes_in_group("player")[0]
	$AnimatedSprite2D.play("Idle")
	$AnimationPlayer.play("Float")


func _process(delta: float) -> void:
	if follow == true:
		global_position = player.global_position


func _on_area_entered(area: Area2D) -> void:
	if player.HP_points < player.max_health:
		follow = true
		$AnimationPlayer.play("healing")
		await get_tree().create_timer(1.6).timeout
		$AnimatedSprite2D.rotation = 0.0
		$AnimatedSprite2D.play("pop-up")
		emit_signal("touched")
		queue_free()
