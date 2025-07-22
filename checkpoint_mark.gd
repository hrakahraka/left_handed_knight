extends Area2D

signal reached

var player = null

func _ready() :
	player = get_tree().get_nodes_in_group("player")[0]
	if player:
		connect("reached", Callable(player, "_on_checkpoint_reached"))


func _on_body_entered(body: Node2D) -> void:
	emit_signal("reached")
