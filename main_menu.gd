extends Control


var save_folder = "res://Saves/"


func _ready() -> void:
	DirAccess.make_dir_recursive_absolute(save_folder)
	$LoadGameWindow.hide()
	$NewGameWindow.hide()
	


func _on_new_game_button_pressed() -> void:
	$NewGameWindow.popup_centered()


func _on_load_game_button_pressed() -> void:
	$LoadGameWindow.popup_centered()


func _on_new_game_window_close_requested() -> void:
	$NewGameWindow.hide()


func _on_load_game_window_close_requested() -> void:
	$LoadGameWindow.hide()


func _on_confirm_new_game_button_pressed() -> void:
	var name = $NewGameWindow/LineEdit.text 
	if not (name == ""):
		if FileAccess.file_exists("res://Saves/" + name + ".LHK"):
			$NewGameWindow/Label.text = "This Name Already Exists"
			return
		save_progress(name)
		Global.player_name = name
		get_tree().change_scene_to_file("res://main.tscn")


func save_progress(name):
	var save_path = save_folder + name + ".LHK"
	var initial_content ={
		"name" = name,
		"xp" = 0,
		"max" = 4,
		"chpos_x" = 0,
		"chpos_y" = 0,
		"lvl" = 1 ,
		"lvl_count" = 0,
		"add_hearts" = 0,
		"damage" = 1,
		"current_level" = "res://main.tscn"
	}
	var file = FileAccess.open(save_path , FileAccess.WRITE)
	var json = JSON.stringify(initial_content)
	file.store_string(json)
	file.close()


func _on_confirm_load_game_button_pressed() -> void:
	pass
