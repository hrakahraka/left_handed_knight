extends Area2D

signal reached
signal entered

var player = null
var checkpoint_on = false

func _ready() :
	player = get_tree().get_nodes_in_group("player")[0]
	if player:
		connect("reached", Callable(player, "_on_checkpoint_reached"))
		connect("entered", Callable(player, "_on_checkpoint_entered"))
	


func _on_body_entered(body: Node2D) -> void:
	if checkpoint_on == false:
		emit_signal("reached")
		$AnimationPlayer.play("coming")
		checkpoint_on = true
	else:
		emit_signal("entered")
		
