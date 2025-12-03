extends Node2D

var player = null

func _ready() -> void:
	player = get_tree().get_nodes_in_group("player")[0]
	$Level1Music.play()


func _process(delta: float) -> void:
	pass
