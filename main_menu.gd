extends Control


var save_folder = "res://Saves/"
var save_files = []
var icon :Texture2D


func _ready() -> void:
	icon = load("res://player_layers/player(Head) _0001.png")
	DirAccess.make_dir_recursive_absolute(save_folder)
	$LoadGameWindow.hide()
	$NewGameWindow.hide()
	load_saves()


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
	var selected_index = $LoadGameWindow/SavesList.get_selected_items()
	if selected_index.size() == 0:
		print("nohing is selected")
		return
	var save_path = save_files[selected_index[0]]
	if FileAccess.file_exists(save_path) == true:
		var file = FileAccess.open(save_path , FileAccess.READ)
		var content = file.get_as_text()
		var save_content = JSON.parse_string(content)
		var load_level = save_content.get("current_level", "res://main.tscn")
		Global.player_name = save_content.get("name", "unknown")
		get_tree().change_scene_to_file(load_level)


func load_saves():
	$LoadGameWindow/SavesList.clear()
	save_files.clear()
	var dir = DirAccess.open(save_folder)
	if dir == null:
		print("error no save file found in res://")
		return
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if not dir.current_is_dir() and file_name.ends_with(".LHK"):
			var file_path = "res://Saves/" + file_name
			var file = FileAccess.open(file_path, FileAccess.READ)
			if file :
				var json_text = file.get_as_text()
				var data = JSON.parse_string(json_text)
				if typeof(data) == TYPE_DICTIONARY:
					var player_name = data.get("name", "unknown") 
					var level = data.get("lvl", 0)
					var display_text = "%s - Level %d" % [player_name, level]
					$LoadGameWindow/SavesList.add_item(display_text, icon)
					save_files.append(file_path)
			file.close()
		file_name = dir.get_next()


func _on_quit_game_button_pressed() -> void:
	pass # Later
