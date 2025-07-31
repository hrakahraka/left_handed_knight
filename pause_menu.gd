extends Control


var main_menu = preload("res://main_menu.tscn")


func _ready() -> void:
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS


func _process(delta: float) -> void:
	pass


func _on_resume_button_pressed() -> void:
	get_tree().paused = false
	visible = false


func _on_main_menu_button_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_packed(main_menu)


func _on_quit_game_button_pressed() -> void:
	get_tree().quit()
