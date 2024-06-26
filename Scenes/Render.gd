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

func _use_tile_data_runtime_update(layer, coords):
	return layer == 4 and coords.x in range(Controller.ap_start_c, Controller.ap_start_c + 2) and coords.y in range(Controller.ap_start_r, Controller.ap_start_r + 4)

func _tile_data_runtime_update(layer, coords, tile_data):
	var ap_x = coords.x - Controller.ap_start_c
	var ap_y = coords.y - Controller.ap_start_r
	#print(layer, "-- ", ap_x, ", ", ap_y)
	if Controller.ap_craft_indicator[ap_x + 2 * ap_y]:
		var i = Controller.ap_craft_indicator[ap_x + 2 * ap_y][1]
		var val
		if Controller.game_ended and i < 0:
				return
		val = Controller.hover_move if i == -1 else Controller.temp_water_break_move if i == -2 else Controller.cur_moves[i]
		match val[4]:
			4:
				tile_data.modulate = Colors.PLANT
			2:
				tile_data.modulate = Colors.CITY
			1:
				tile_data.modulate = Colors.HILL
			_:
				return

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if offset == 0:
		var mouse_position = get_global_mouse_position()
		mouse_position -= position
		Controller.mouse_tile_hover = local_to_map(mouse_position)
		if get_tree().current_scene.name == "map_editor":
			render_inventory()
		else:
			render_ap_crafter()
			clear_layer(5)
			if Controller.path != null and Controller.path.size() > 1 and Controller.mouse_step > 0:
				for pi in Controller.path.size():
					set_cell(5, Controller.path[pi], 0, Vector2i(2, get_path_neighbors(Controller.path, pi)))
			notify_runtime_tile_data_update(5)

func delta_to_neighbor_index(dp):
	match dp:
		Vector2i(0, 1):
			return 0
		Vector2i(1, 0):
			return 1
		Vector2i(0, -1):
			return 2
		Vector2i(-1, 0):
			return 3

func get_path_neighbors(path, pi):
	var neighbors = [false, false, false, false]
	if pi > 0:
		neighbors[delta_to_neighbor_index(path[pi] - path[pi-1])] = true
	if pi < path.size() - 1:
		neighbors[delta_to_neighbor_index(path[pi] - path[pi+1])] = true
	var path_end_offset = 0 if pi == 0 else 10
	match neighbors:
		[true, false, false, false]:
			return path_end_offset
		[false, true, false, false]:
			return path_end_offset + 1
		[false, false, true, false]:
			return path_end_offset + 2
		[false, false, false, true]:
			return path_end_offset + 3
		[true, true, false, false]:
			return 4
		[false, true, true, false]:
			return 5
		[false, false, true, true]:
			return 6
		[true, false, false, true]:
			return 7
		[true, false, true, false]:
			return 8
		[false, true, false, true]:
			return 9

func render_inventory():
	set_cell(4, Vector2i(Controller.ap_start_c, Controller.ap_start_r), 0,  Vector2i(0,4))
	set_cell(4, Vector2i(Controller.ap_start_c+1, Controller.ap_start_r), 0,  Vector2i(0,5))
	set_cell(4, Vector2i(Controller.ap_start_c, Controller.ap_start_r+1), 0,  Vector2i(0,3))
	set_cell(4, Vector2i(Controller.ap_start_c+1, Controller.ap_start_r+1), 0,  Vector2i(0,1))
	set_cell(4, Vector2i(Controller.ap_start_c, Controller.ap_start_r+2), 0,  Vector2i(0,2))
	set_cell(4, Vector2i(Controller.ap_start_c-1, Controller.ap_start_r+3), 0,  Vector2i(0,27))
	set_cell(4, Vector2i(Controller.ap_start_c, Controller.ap_start_r+3), 0,  Vector2i(2,15))
	set_cell(4, Vector2i(Controller.ap_start_c+1, Controller.ap_start_r+3), 0,  Vector2i(2,14))
	set_cell(4, Vector2i(Controller.ap_start_c+2, Controller.ap_start_r+3), 0,  Vector2i(2,16))
	
func render_ap_crafter():
	Controller.fill_ap_craft_indicator()
	if not Controller.ap_craft_render_update:
		return
	clear_layer(4)
	for i in Controller.ap_craft_indicator.size():
		if Controller.ap_craft_indicator[i] == null:
			continue
		var blink = 12 if Controller.ap_craft_indicator[i][1] < 0 else 0
		var pos = Vector2i(Controller.ap_start_c + i % 2, Controller.ap_start_r + i / 2)
		match Controller.ap_craft_indicator[i][0]:
			6:
				set_cell(4, pos, 0, Vector2i(3 + i % 2, 9 + i / 2 + blink))
			5:
				set_cell(4, pos, 0, Vector2i(3 + i % 2, 6 + i / 2 + blink))
			4:
				set_cell(4, pos, 0, Vector2i(3 + i % 2, 4 + i / 2 + blink))
			3:
				set_cell(4, pos, 0, Vector2i(3, 1 + i / 2 + blink))
			2 when i < 4:
				set_cell(4, pos, 0, Vector2i(4, 1 + i / 2 + blink))
			2:
				set_cell(4, pos, 0, Vector2i(3 + i % 2, 0 + blink))
			1:
				set_cell(4, pos, 0, Vector2i(4, 3 + blink))
	notify_runtime_tile_data_update(4)
	Controller.ap_craft_render_update = false

func render_tree_waterlogged(r, c):
	return Vector2i(1, 8) if not Controller.game_ended and Controller.is_tile_watterlogged(r, c) else Vector2i(0, 1)

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
			set_cell(3, Vector2i(Controller.view_tick, Controller.tick_start_r), 0, Vector2i(1, 0))
		else:
			set_cell(3, Vector2i(Controller.tick_counter, Controller.tick_start_r), 0, Vector2i(1, 0))
			for water in Controller.waters_to_break:
				set_cell(3, Vector2i(water[1], water[0]), 0, Vector2i(1, 0))
		notify_runtime_tile_data_update(3)

func get_render_neighbors(r, c): # counter-clockwise from top
	return [r > 0 and Controller.init_array[r-1][c]==0,
			c > 0 and Controller.init_array[r][c-1]==0,
			r < Controller.board_height - 1 and Controller.init_array[r+1][c]==0,
			c < Controller.board_length - 1 and Controller.init_array[r][c+1]==0]

func get_land_render_tile(neighbors):
	match neighbors:
		[true, true, true, true]:
			return Vector2i(0, 6)

		[true, true, false, true]:
			return Vector2i(1, 23)
		[true, true, true, false]:
			return Vector2i(0, 24)
		[false, true, true, true]:
			return Vector2i(0, 23)
		[true, false, true, true]:
			return Vector2i(1, 24)

		[true, true, false, false]:
			return Vector2i(0, 18)
		[true, false, false, true]:
			return Vector2i(1, 18)
		[false, true, true, false]:
			return Vector2i(0, 19)
		[false, false, true, true]:
			return Vector2i(1, 19)
		[true, false, true, false]:
			return Vector2i(0, 22)
		[false, true, false, true]:
			return Vector2i(1, 22)

		[false, true, false, false]:
			return Vector2i(0, 20)
		[false, false, false, true]:
			return Vector2i(1, 20)
		[false, false, true, false]:
			return Vector2i(1, 21)
		[true, false, false, false]:
			return Vector2i(0, 21)

		[false, false, false, false]:
			return Vector2i(0, 5)

func _on_game_board_render_background():
	if offset == 0:
		clear_layer(0)
		clear_layer(2)
		var r = 0
		for rd in Controller.init_array:
			var c = 0
			for cd in rd:
				if cd == 0 or cd == 4:
					set_cell(0, Vector2i(c, r), 0, Vector2i(0, cd + 4))
				else:
					var tl = get_land_render_tile(get_render_neighbors(r, c))
					set_cell(0, Vector2i(c, r), 0, tl)
				c+=1
			r+=1
		for c in Controller.tick_array.size():
			set_cell(0, Vector2i(c, Controller.tick_start_r), 0, Vector2i(1, abs(Controller.tick_array[c]) + 1))
			if Controller.tick_array[c] < 0:
				set_cell(2, Vector2i(c, Controller.tick_start_r), 0, Vector2i(1, 7))

		set_cell(0, Vector2i(Controller.ap_start_c, Controller.ap_start_r), 0, Vector2i(1, 1))
		set_cell(0, Vector2i(Controller.ap_start_c, Controller.ap_start_r+1), 0, Vector2i(1, 1))
		set_cell(0, Vector2i(Controller.ap_start_c, Controller.ap_start_r+2), 0, Vector2i(1, 1))
		set_cell(0, Vector2i(Controller.ap_start_c+1, Controller.ap_start_r), 0, Vector2i(1, 1))
		set_cell(0, Vector2i(Controller.ap_start_c+1, Controller.ap_start_r+1), 0, Vector2i(1, 1))
		set_cell(0, Vector2i(Controller.ap_start_c+1, Controller.ap_start_r+2), 0, Vector2i(1, 1))

		if Controller.tick_counter == Controller.tick_array.size() - 1:
			set_cell(0, Vector2i(Controller.ap_start_c-1, Controller.ap_start_r+3), 0, Vector2i(0,27))
			set_cell(0, Vector2i(Controller.ap_start_c+2, Controller.ap_start_r+3), 0, Vector2i(1,27))
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
		mouse_position -= position
		Controller.mouse_tile_position = local_to_map(mouse_position)


func _on_label_render_end():
	_on_game_board_render()
	_on_game_board_render_background()
