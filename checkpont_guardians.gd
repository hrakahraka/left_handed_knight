extends Node2D


func _ready() -> void:
	visible = false
	$AnimatedSprite2D.play("idle")
	$AnimationPlayer.play("Float")


func _on_checkpoint_mark_reached() -> void:
	visible = true
