extends Node

signal render_background
signal render
signal city_destroy
signal tree_plant
signal mountain_move
signal city_move
signal tree_move

@onready var city_flooder = preload("res://city_animated_sprite.tscn")
@onready var tree_flooder = preload("res://tree_animated_sprite.tscn")

func _ready():
	Controller.astar_mutex = Mutex.new()
	load_array()
	render.emit()
	render_background.emit()

func _process(delta):
	pass
func _input(event):
	if Input.is_action_just_pressed("Click"):
		if Controller.tick_counter == Controller.tick_array.size() - 1:
			if Controller.mouse_tile_position.y == Controller.tick_start_r and Controller.mouse_tile_position.x <= Controller.tick_counter:
				Controller.view_historical_tick(Controller.mouse_tile_position.x)
				render.emit()
			elif Controller.mouse_tile_position.y == Controller.ap_start_r+3:
				if Controller.mouse_tile_position.x == Controller.ap_start_c:
					Controller.is_paused = false
					render_background.emit()
				elif Controller.mouse_tile_position.x == Controller.ap_start_c+1:
					Controller.is_paused = true
					render_background.emit()
				elif Controller.mouse_tile_position.x==Controller.ap_start_c-1:
					get_tree().change_scene_to_file("res://main_menu.tscn")
				elif Controller.mouse_tile_position.x == Controller.ap_start_c+2:
					var img = self.get_viewport().get_texture().get_image()
					img.save_png("user://screenshot.png")
					Controller.download_file(img, "win", true)
					
			return
		if Controller.waters_to_break != []:
			for w in Controller.waters_to_break:
				if w[0] == Controller.mouse_tile_position.y and w[1] == Controller.mouse_tile_position.x:
					Controller.process_water_break(w[0], w[1])
					render.emit()
					return
		elif Controller.mouse_tile_position.x < Controller.board_length and Controller.mouse_tile_position.y < Controller.board_height:
			Controller.cycleTile()
			render.emit()
		elif Controller.mouse_tile_position.x in range(Controller.ap_start_c, Controller.ap_start_c + 2):
			if Controller.mouse_tile_position.y in range(Controller.ap_start_r, Controller.ap_start_r + 3):
				var click_pos = 2 * (Controller.mouse_tile_position.y - Controller.ap_start_r) + Controller.mouse_tile_position.x - Controller.ap_start_c
				if Controller.ap_craft_indicator[click_pos] == null:
					return
				Controller.undo_move(Controller.ap_craft_indicator[click_pos][1])
				render.emit()
			elif Controller.mouse_tile_position.y == Controller.ap_start_r + 3:
				process_game_tick()
				render.emit()
	if Input.is_action_just_pressed("Right Click"):
		if Controller.tick_counter == Controller.tick_array.size():
			Controller.view_historical_tick(Controller.tick_counter)
			render.emit()
		else:
			Controller.mouse_step = 0
			Controller.pathfind_update_flag = 0

func load_array():
	Controller.load_map()
	Controller.water_array.resize(Controller.board_length)
	Controller.water_array.fill(0)
	Controller.wrs.resize(Controller.board_length)
	Controller.wrs.fill([0,0])
 
	Controller.astar_mutex.lock()
	Controller.astar_grid.region = Rect2i(0, 0, Controller.board_length, Controller.board_height)
	Controller.astar_grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	Controller.astar_grid.default_compute_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
	Controller.astar_grid.default_estimate_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
	Controller.astar_grid.update()
	Controller.astar_mutex.unlock()
  
	process_game_tick()

func process_game_tick():
	if not Controller.game_ended:
		Controller.mouse_step = 0
		Controller.fill_ap_craft_indicator()
		Controller.historical_game_states.append([Controller.tile_array.duplicate(true), Controller.wrs.duplicate(true), Controller.ap_craft_indicator.duplicate(true)])
		Controller.tick_counter += 1
		print("flooding %d%s" % [abs(Controller.tick_array[Controller.tick_counter]), ", try spawning plants" if Controller.tick_array[Controller.tick_counter] < 0 else ""])
		for i in abs(Controller.tick_array[Controller.tick_counter]):
			create_wave()
		if Controller.tick_array[Controller.tick_counter] < 0:
			try_spawn_plants()
		Controller.ap = 6
		for mov in Controller.cur_moves:
			match mov[4]:
				4:
					Controller.trees_moved += 1
					tree_move.emit()
				2:
					Controller.cities_moved += 1
					city_move.emit()
				1:
					Controller.terrain_moved += 1
					mountain_move.emit()
		Controller.cur_moves = []
		for winfo in Controller.pending_broken_waters:
			if winfo == null:
				continue
			Controller.tile_array[winfo[0]][winfo[1]] &= ~4
			print("spawn anim")
			var anim = tree_flooder.instantiate()
			anim.position = Vector2i(winfo[1], winfo[0]) * Colors.TILE_SIZE
			add_child(anim)
		Controller.pending_broken_waters = []
		Controller.ap_craft_indicator.fill(null)
		if Controller.tick_counter == Controller.tick_array.size() - 1:
			Controller.game_ended = true
			Controller.historical_game_states.append([Controller.tile_array, Controller.wrs, Controller.ap_craft_indicator])
			print("done; %d cities survived" % Controller.count_surviving_cities())
	else:
		print("done; %d cities survived" % Controller.count_surviving_cities())

func create_wave():
	var col = Controller.get_flood_column()
	Controller.water_array[col] += 1
	Controller.wrs[col] = Controller.calculate_water_reach(col)
	check_grass_absorb(col)
	check_destroy_city(col)


	
func try_spawn_plants():
	for r in Controller.board_height:
		for c in Controller.board_length:
			var max_reach = max(Controller.wrs[c][0], Controller.wrs[c][1]) - 1
			if Controller.init_array[r][c] == 4 and Controller.tile_array[r][c] == 0 and max_reach < r:
				Controller.trees_planted += 1
				tree_plant.emit()
				Controller.count_adjacent_water_tiles(r, c)
				if Controller.waters_to_break.size() > 0:
					var col = Controller.waters_to_break[0][1]
					Controller.water_array[col] -= 1
					Controller.wrs[col] = Controller.calculate_water_reach(col)
					var anim = tree_flooder.instantiate()
					anim.position = Vector2i(c, r) * Colors.TILE_SIZE
					add_child(anim)
					Controller.waters_to_break = []
				else:
					Controller.tile_array[r][c] |= 4

func check_grass_absorb(col): # this just checks if extant, unmoved grass absorbs a single new water tile; grass tile movement should go somewhere else
	var max_reach = max(Controller.wrs[col][0], Controller.wrs[col][1]) - 1
	if max_reach < 0 or max_reach >= Controller.board_height:
		return
	var pos = null
	if max_reach + 1 < Controller.board_height and Controller.tile_array[max_reach+1][col] & 4 > 0:
		pos = Vector2i(col, max_reach+1)	
	elif col > 0 and Controller.tile_array[max_reach][col-1] & 4 > 0:
		pos = Vector2i(col-1, max_reach)
	elif col < Controller.board_length-1 and Controller.tile_array[max_reach][col+1] & 4 > 0:
		pos = Vector2i(col+1, max_reach)

	if pos != null:
		Controller.water_array[col] -= 1
		Controller.tile_array[pos.y][pos.x] &= ~4
		Controller.wrs[col] = Controller.calculate_water_reach(col)
		var anim = tree_flooder.instantiate()
		anim.position = pos * Colors.TILE_SIZE
		add_child(anim)

func check_destroy_city(col):
	var max_reach = max(Controller.wrs[col][0], Controller.wrs[col][1]) - 1
	if max_reach < 0 or max_reach >= Controller.board_height:
		return
	if Controller.tile_array[max_reach][col] & 2 > 0:
		Controller.tile_array[max_reach][col] &= ~2
		var anim = city_flooder.instantiate()
		anim.position = Vector2i(col, max_reach) * Colors.TILE_SIZE
		add_child(anim)
		city_destroy.emit()
