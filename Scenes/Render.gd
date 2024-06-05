extends TileMap

var offset = -1

# Called when the node enters the scene tree for the first time.
func _ready():
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
				set_cell(lr, Vector2i(c, r), 0, Vector2i(0, 1))
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
		set_cell(3, Vector2i(Controller.tick_counter, r), 0, Vector2i(0, 9))
		notify_runtime_tile_data_update(3)
	
func _on_game_board_render_background():
	if offset == 0:
		clear_layer(0)
		var r = 0
		for rd in Controller.init_array:
			var c = 0
			for cd in rd:
				set_cell(0, Vector2i(c, r), 0, Vector2i(0, cd + 4))
				c+=1
			r+=1
		for c in Controller.tick_array.size():
			set_cell(0, Vector2i(c, r), 0, Vector2i(0, abs(Controller.tick_array[c]) + 10))
			if Controller.tick_array[c] < 0:
				set_cell(2, Vector2i(c, r), 0, Vector2i(0, 16))
		notify_runtime_tile_data_update()
func _input(event):
	if Input.is_action_just_pressed("Click") and offset==0:
		var mouse_position = get_global_mouse_position()
		Controller.mouse_tile_position = local_to_map(mouse_position)
		print(Controller.mouse_tile_position)
