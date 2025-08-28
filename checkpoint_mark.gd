extends Area2D

signal reached

var player = null
var checkpoint_on = false

func _ready() :
	player = get_tree().get_nodes_in_group("player")[0]
	if player:
		connect("reached", Callable(player, "_on_checkpoint_reached"))
	


func _on_body_entered(body: Node2D) -> void:
	emit_signal("reached")
	if checkpoint_on == false:
		$AnimationPlayer.play("Appear")
		checkpoint_on = true
