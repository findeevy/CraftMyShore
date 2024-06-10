extends TileMap

var offset = -1

var previous_game = "";
var previous_game_text = "";
var file_written = false;
var file_exist = FileAccess.file_exists("res://previousGame.dat")

# Called when the node enters the scene tree for the first time.
func _ready():
	if file_exist:
		previous_game=FileAccess.open("res://previousGame.dat", FileAccess.READ)
	else:
		FileAccess.open("res://previousGame.dat", FileAccess.WRITE)
		previous_game=FileAccess.open("res://previousGame.dat", FileAccess.READ)
	match name:
		"TileMap":
			offset = 0
		"TileMap2":
			offset = 1
		"TileMap3":
			offset = 2

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var mouse_position = get_global_mouse_position()
	Controller.mouse_tile_hover = local_to_map(mouse_position)

func render_tree_waterlogged(r, c):
	return Vector2i(1, 8) if Controller.is_tile_watterlogged(r, c) else Vector2i(0, 1)

func _on_game_board_render():
	var lr = 1 if offset == 0 else 0
	clear_layer(lr)
	var r = 0
	for rd in Controller.tile_array:
		var c = 0
		for cd in rd:
			if cd & 4 == 0 and offset == 0 and r < Controller.wrs[c][0]:
				set_cell(lr, Vector2i(c, r), 0, Vector2i(0, 0))
			elif offset == 2 and r < Controller.wrs[c][1]:
				set_cell(lr, Vector2i(c, r), 0, Vector2i(0, 0))
			elif cd & 4 > 0 and offset == 0:
				set_cell(lr, Vector2i(c, r), 0, render_tree_waterlogged(r, c))
			elif cd & 2 > 0 and offset == 0:
				set_cell(lr, Vector2i(c, r), 0, Vector2i(0, 2))
			elif cd & 1 > 0 and offset == 0:
				set_cell(lr, Vector2i(c, r), 0, Vector2i(0, 3))
			elif cd & 6 == 6 and offset == 1:
				set_cell(lr, Vector2i(c, r), 0, Vector2i(0, 2))
			elif (cd + 2) & 5 == 5 and offset == 1:
				set_cell(lr, Vector2i(c, r), 0, Vector2i(0, 3))
			elif cd == 7 and offset == 2:
				set_cell(lr, Vector2i(c, r), 0, Vector2i(0, 3))
			c+=1
		r+=1
	notify_runtime_tile_data_update(lr)
	if offset == 0:
		clear_layer(3)
		if Controller.tick_counter == Controller.tick_array.size() - 1:
			set_cell(3, Vector2i(Controller.view_tick, r), 0, Vector2i(1, 0))
		else:
			set_cell(3, Vector2i(Controller.tick_counter, r), 0, Vector2i(1, 0))
			for i in Controller.ap_craft_indicator.size():
				if Controller.ap_craft_indicator[i] == null:
					continue
				match Controller.ap_craft_indicator[i][0]:
					3:
						set_cell(3, Vector2i(Controller.ap_start_c + i % 2, Controller.ap_start_r + i / 2), 0, Vector2i(0, 11 + i / 2))
					2 when i < 4:
						set_cell(3, Vector2i(Controller.ap_start_c + i % 2, Controller.ap_start_r + i / 2), 0, Vector2i(1, 11 + i / 2))
					2:
						set_cell(3, Vector2i(Controller.ap_start_c + i % 2, Controller.ap_start_r + i / 2), 0, Vector2i(i % 2, 10))
					1:
						set_cell(3, Vector2i(Controller.ap_start_c + i % 2, Controller.ap_start_r + i / 2), 0, Vector2i(1, 13))
			for water in Controller.waters_to_break:
				set_cell(3, Vector2i(water[1], water[0]), 0, Vector2i(1, 0))
		notify_runtime_tile_data_update(3)
	
func _on_game_board_render_background():
	if offset == 0:
		clear_layer(0)
		var r = 0
		for rd in Controller.init_array:
			var c = 0
			for cd in rd:
				if cd == 0:
					set_cell(0, Vector2i(c, r), 0, Vector2i(0, 4))
				else:
					if c > 0 and Controller.init_array[r][c-1]==0 and r > 0 and Controller.init_array[r-1][c]==0 and c <= Controller.board_height and Controller.init_array[r][c+1]==0:
						set_cell(0, Vector2i(c, r), 0, Vector2i(1, 23))
					elif c <= Controller.board_height and Controller.init_array[r][c+1]==0 and r > 0 and Controller.init_array[r-1][c]==0 and r < Controller.board_length - 3 and Controller.init_array[r+1][c]==0:
						set_cell(0, Vector2i(c, r), 0, Vector2i(1, 24))
					elif c > 0 and Controller.init_array[r][c-1]==0 and r > 0 and Controller.init_array[r+1][c]==0 and c <= Controller.board_height and Controller.init_array[r][c+1]==0:
						set_cell(0, Vector2i(c, r), 0, Vector2i(0, 23))
					elif c < Controller.board_height and Controller.init_array[r][c-1]==0 and r < Controller.board_length - 3 and Controller.init_array[r+1][c]==0 and  r > 0 and Controller.init_array[r+1][c]==0:
						set_cell(0, Vector2i(c, r), 0, Vector2i(0, 24))
					elif c > 0 and Controller.init_array[r][c-1]==0 and r > 0 and Controller.init_array[r-1][c]==0:
						set_cell(0, Vector2i(c, r), 0, Vector2i(0, 18))
					elif c <= Controller.board_height and Controller.init_array[r][c+1]==0 and r > 0 and Controller.init_array[r-1][c]==0:
						set_cell(0, Vector2i(c, r), 0, Vector2i(1, 18))
					elif c > 0 and Controller.init_array[r][c-1]==0 and r > 0 and Controller.init_array[r+1][c]==0:
						set_cell(0, Vector2i(c, r), 0, Vector2i(0, 19))
					elif c < Controller.board_height and Controller.init_array[r][c+1]==0 and r < Controller.board_length - 3 and Controller.init_array[r+1][c]==0:
						set_cell(0, Vector2i(c, r), 0, Vector2i(1, 19))
					elif r > 0 and Controller.init_array[r-1][c]==0 and  r < Controller.board_length - 3 and Controller.init_array[r+1][c]==0:
						set_cell(0, Vector2i(c, r), 0, Vector2i(0, 22))
					elif c > 0 and Controller.init_array[r][c-1]==0 and c < Controller.board_height and Controller.init_array[r][c+1]==0:
						set_cell(0, Vector2i(c, r), 0, Vector2i(1, 22))
					elif c > 0 and Controller.init_array[r][c-1]==0:
						set_cell(0, Vector2i(c, r), 0, Vector2i(0, 20))
					elif c < Controller.board_height and Controller.init_array[r][c+1]==0:
						set_cell(0, Vector2i(c, r), 0, Vector2i(1, 20))
					#not sure why this requires a "-3", board_length seems to be working alright?
					elif r < Controller.board_length - 3 and Controller.init_array[r+1][c]==0:
						set_cell(0, Vector2i(c, r), 0, Vector2i(1, 21))
					elif r > 0 and Controller.init_array[r-1][c]==0:
						set_cell(0, Vector2i(c, r), 0, Vector2i(0, 21))
					else:
						set_cell(0, Vector2i(c, r), 0, Vector2i(0, 5))
				c+=1
			r+=1
		for c in Controller.tick_array.size():
			set_cell(0, Vector2i(c, r), 0, Vector2i(1, abs(Controller.tick_array[c]) + 1))
			if Controller.tick_array[c] < 0:
				set_cell(2, Vector2i(c, r), 0, Vector2i(1, 7))
				
		set_cell(0, Vector2i(Controller.ap_start_c, Controller.ap_start_r), 0, Vector2i(1, 1))
		set_cell(0, Vector2i(Controller.ap_start_c, Controller.ap_start_r+1), 0, Vector2i(1, 1))
		set_cell(0, Vector2i(Controller.ap_start_c, Controller.ap_start_r+2), 0, Vector2i(1, 1))
		set_cell(0, Vector2i(Controller.ap_start_c+1, Controller.ap_start_r), 0, Vector2i(1, 1))
		set_cell(0, Vector2i(Controller.ap_start_c+1, Controller.ap_start_r+1), 0, Vector2i(1, 1))
		set_cell(0, Vector2i(Controller.ap_start_c+1, Controller.ap_start_r+2), 0, Vector2i(1, 1))
		
		if Controller.tick_counter == Controller.tick_array.size() - 1:
			if Controller.is_paused:
				set_cell(0, Vector2i(Controller.ap_start_c, Controller.ap_start_r+3), 0, Vector2i(0, 25))
				set_cell(0, Vector2i(Controller.ap_start_c+1, Controller.ap_start_r+3), 0, Vector2i(1, 26))
			else:
				set_cell(0, Vector2i(Controller.ap_start_c, Controller.ap_start_r+3), 0, Vector2i(0, 26))
				set_cell(0, Vector2i(Controller.ap_start_c+1, Controller.ap_start_r+3), 0, Vector2i(1, 25))
		else:
			set_cell(0, Vector2i(Controller.ap_start_c, Controller.ap_start_r+3), 0, Vector2i(0, 9))
			set_cell(0, Vector2i(Controller.ap_start_c+1, Controller.ap_start_r+3), 0, Vector2i(1, 9))
		
		notify_runtime_tile_data_update()
func _input(event):
	if Input.is_action_just_pressed("Click") and offset==0:
		var mouse_position = get_global_mouse_position()
		Controller.mouse_tile_position = local_to_map(mouse_position)


func _on_label_render_end():
	_on_game_board_render()
	_on_game_board_render_background()
