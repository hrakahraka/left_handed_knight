extends CanvasLayer

signal respawn

@onready var heart_container = $HeartContainer
var full_heart = preload("res://HUD/hearts/Heart_full.png")
var empty_heart = preload("res://HUD/hearts/Heart_empty.png")
var player = null


func _ready() -> void:
	player = get_tree().get_nodes_in_group("player")[0]
	update_heart()
	
	
func update_heart():
	for i in range(player.max_health):
		var heart = heart_container.get_child(i)
		if i < player.HP_points:
			heart.texture = full_heart
		else:
			heart.texture = empty_heart


func add_heart():
	var new_heart = TextureRect.new()
	new_heart.texture = full_heart
	new_heart.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	heart_container.add_child(new_heart)
	update_heart()


func _on_respawn_button_pressed() -> void:
	$RespawnButton.visible = false
	emit_signal("respawn")
