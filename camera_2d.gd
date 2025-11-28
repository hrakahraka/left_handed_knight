extends Camera2D

var shake_strength: float
var shake_duration: float
var time_left = 0.0
var original_offset : Vector2
@export var world_rect : Rect2


func _ready() -> void:
	original_offset = offset
	
	
func shake(strength , duration):
	shake_duration = duration
	time_left = shake_duration
	shake_strength = strength
	
	
func _process(delta: float) -> void:
	if time_left > 0.0:
		time_left -= delta
		offset = original_offset + Vector2(randf_range(-1,1),randf_range(-1,1))*shake_strength*(time_left / shake_duration)
	else:
		offset = original_offset


func _on_player_player_hit() -> void:
	shake(3.0 , 0.5)
