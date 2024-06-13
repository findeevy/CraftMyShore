extends Node2D

@onready var map_options = $MapOptionButton
var opts = []

func _ready():
	Controller.platform_type=OS.get_name()
	var map_dir = DirAccess.open("res://Maps/")
	for f in map_dir.get_files():
		print(f)
		if f.length() > 4 and f.substr(f.length() - 4) == ".dat":
			opts.append(f)
			map_options.add_item(f.substr(0, f.length() - 4).replace("_", " ").to_upper())

func _on_map_button_down():
	if map_options.selected >= 0:
		Controller.file_name = opts[map_options.selected]
	get_tree().change_scene_to_file("res://Scenes/map_editor.tscn")

func _on_play_button_down():
	if map_options.selected >= 0:
		Controller.file_name = opts[map_options.selected]
	get_tree().change_scene_to_file("res://Scenes/game_board.tscn")
