extends Node

signal render_background
signal render
signal save_map_file
signal load_map_file

@onready var city_flooder = preload("res://city_animated_sprite.tscn")
@onready var tree_flooder = preload("res://tree_animated_sprite.tscn")

func _ready():
	load_array("easy_bay.dat")
	render.emit()
	render_background.emit()

func _process(delta):
	pass
	
func _input(event):
	if Input.is_action_just_pressed("Right Click"):
		if Controller.mouse_tile_position.y == Controller.board_height and Controller.mouse_tile_position.x <= Controller.tick_array.size():
			Controller.tick_array[Controller.mouse_tile_position.x] = -1*(Controller.tick_array[Controller.mouse_tile_position.x])
			render.emit()
			render_background.emit()
	if Input.is_action_just_pressed("Click"):
		if Controller.mouse_tile_position.x < Controller.board_length and Controller.mouse_tile_position.y < Controller.board_height:
			map_cycle()
			render.emit()
		elif Controller.mouse_tile_position==Vector2i(Controller.ap_start_c+1,Controller.ap_start_r):
			Controller.selected_tile="l"
		elif Controller.mouse_tile_position==Vector2i(Controller.ap_start_c,Controller.ap_start_r):
			Controller.selected_tile="w"
		elif Controller.mouse_tile_position==Vector2i(Controller.ap_start_c,Controller.ap_start_r+2):
			Controller.selected_tile="c"
		elif Controller.mouse_tile_position==Vector2i(Controller.ap_start_c,Controller.ap_start_r+1):
			Controller.selected_tile="t"
		elif Controller.mouse_tile_position==Vector2i(Controller.ap_start_c+1,Controller.ap_start_r+1):
			Controller.selected_tile="v"
		elif Controller.mouse_tile_position==Vector2i(Controller.ap_start_c+2,Controller.ap_start_r+3):
			for l in Controller.init_array:
				l.fill(0)
			for l in Controller.tile_array:
				l.fill(0)
			render.emit()
			render_background.emit()
		elif Controller.mouse_tile_position==Vector2i(Controller.ap_start_c-1,Controller.ap_start_r+3):
			get_tree().change_scene_to_file("res://main_menu.tscn")
		elif Controller.mouse_tile_position==Vector2i(Controller.ap_start_c+1,Controller.ap_start_r+3):
			save_map()
		elif Controller.mouse_tile_position==Vector2i(Controller.ap_start_c,Controller.ap_start_r+3):
			load_map()
		elif Controller.mouse_tile_position.y == Controller.board_height and Controller.mouse_tile_position.x <= Controller.tick_array.size():
			Controller.tick_array[Controller.mouse_tile_position.x] = (Controller.tick_array[Controller.mouse_tile_position.x] + 1 ) % 6
			render.emit()
			render_background.emit()

func load_map():
	#load_map_file.emit()
	JavaScriptBridge.eval("var input=document.createElement('input'); input.setAttribute('type', 'file'); input.setAttribute('id', 'fileForUpload'); input.setAttribute('accept', '.dat'); (input).click();", true)

func save_map():
	Controller.export_string=""
	for i in Controller.init_array:
		for j in i:
			match j:
					3:
						Controller.export_string+="t"
					2:
						Controller.export_string+="c"
					0:
						Controller.export_string+="w"
					4:
						Controller.export_string+="v"
					1:
						Controller.export_string+="l"
		Controller.export_string+=("\n")
	Controller.export_string+=("gea: ")
	for ki in Controller.tick_array.size():
		var k = Controller.tick_array[ki]
		if ki < Controller.tick_array.size()-1:
			Controller.export_string+=str(k)+", "
		else:
			Controller.export_string+=str(k)
	Controller.export_string+=("\n")
	Controller.download_file(Controller.export_string.to_utf8_buffer ( ),"map.dat",false)

func map_cycle():
	match Controller.selected_tile:
		"w":
			Controller.init_array[Controller.mouse_tile_position.y][Controller.mouse_tile_position.x]=0
			Controller.tile_array[Controller.mouse_tile_position.y][Controller.mouse_tile_position.x]=0
		"l":
			Controller.init_array[Controller.mouse_tile_position.y][Controller.mouse_tile_position.x]=1
			Controller.tile_array[Controller.mouse_tile_position.y][Controller.mouse_tile_position.x]=0
		"c":
			Controller.init_array[Controller.mouse_tile_position.y][Controller.mouse_tile_position.x]=2
			Controller.tile_array[Controller.mouse_tile_position.y][Controller.mouse_tile_position.x]=2
		"v":
			Controller.init_array[Controller.mouse_tile_position.y][Controller.mouse_tile_position.x]=4
			Controller.tile_array[Controller.mouse_tile_position.y][Controller.mouse_tile_position.x]=4
		"t":
			Controller.init_array[Controller.mouse_tile_position.y][Controller.mouse_tile_position.x]=3
			Controller.tile_array[Controller.mouse_tile_position.y][Controller.mouse_tile_position.x]=1
	render.emit()
	render_background.emit()

func load_array(file_name):
	Controller.file_name = file_name
	Controller.load_map()
	Controller.water_array.resize(Controller.board_length)
	Controller.water_array.fill(0)
	Controller.wrs.resize(Controller.board_length)
	Controller.wrs.fill([0,0])
	print(Controller.init_array)


func _on_load_dialog_finalize_load():
	load_array(Controller.loaded_file)
	render.emit()
	render_background.emit()
