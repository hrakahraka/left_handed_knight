extends Node2D


func _ready() -> void:
	$AnimatedSprite2D.play("idle")
	$AnimationPlayer.play("Float")
