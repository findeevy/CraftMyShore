extends Node

var init_array = []
var tile_array = []

var board_length = 0
var board_height = 0

var water_array = []
var wrs = []

var rng = RandomNumberGenerator.new()

var tick_counter = -1
var tick_array = [0, 1, 1, 1, 1, 2, -2, 2, 2, -2, 3, 3, -3, 3, 3, -3, 5]
# number of dice to roll per turn; negative numbers also spawn plants

var ap_start_r = 1
var ap_start_c = 1

var mouse_tile_position = Vector2i(0,0)
var mouse_tile_hover = Vector2i(0,0)
var mouse_tile_selected = Vector2i(0,0)
var mouse_step = 0

func load_array(file_name):
	var f = FileAccess.open("res://" + file_name, FileAccess.READ)
	while f.get_position() < f.get_length():
		var l = f.get_line()
		var id = []
		var td = []
		for c in l:
			match c:
				"l":
					id.append(1)
					td.append(0)
				"c":
					id.append(2)
					td.append(2)
				"w":
					id.append(0)
					td.append(0)
				"v":
					id.append(4)
					td.append(4)
				"t":
					id.append(3)
					td.append(1)
		init_array.append(id)
		tile_array.append(td)
	board_length = init_array[0].size()
	board_height = init_array.size()
	ap_start_c = board_length + 1
	water_array.resize(board_length)
	water_array.fill(0)
	wrs.resize(board_length)
	wrs.fill([0,0])
	process_game_tick()

func calculate_water_reach(col):
	var vol = water_array[col]
	var reach = 0
	var high_reach = 0
	while vol > 0:
		if high_reach >= board_height:
			break
		vol -= 1
		if reach < board_height and tile_array[reach][col] & 1 > 0:
			if high_reach <= reach:
				high_reach += 1
			else:
				reach += 2
		else:
			reach += 1
	return [reach, high_reach]

func check_grass_absorb(col): # this just checks if grass absorbs a single new water tile; grass tile movement should go somewhere else
	var max_reach = max(wrs[col][0], wrs[col][1]) - 1
	if max_reach < 0:
		return
	if max_reach + 1 < board_height and tile_array[max_reach+1][col] & 4 > 0:
		water_array[col] -= 1
		tile_array[max_reach+1][col] &= ~4
		print("col %d destroyed grass down" % col)
		wrs[col] = calculate_water_reach(col)
	elif col > 0 and tile_array[max_reach][col-1] & 4 > 0:
		water_array[col] -= 1
		tile_array[max_reach][col-1] &= ~4
		print("col %d destroyed grass left" % col)
		wrs[col] = calculate_water_reach(col)
	elif col < board_length-1 and tile_array[max_reach][col+1] & 4 > 0:
		water_array[col] -= 1
		tile_array[max_reach][col+1] &= ~4
		print("col %d destroyed grass right" % col)
		wrs[col] = calculate_water_reach(col)

func check_destroy_city(col):
	var max_reach = max(wrs[col][0], wrs[col][1]) - 1
	if max_reach < 0:
		return
	if tile_array[max_reach][col] & 2 > 0:
		tile_array[max_reach][col] &= ~2
		print("col %d destroyed city" % col)

func get_flood_column():
	if board_length == 11:
		return rng.randi_range(1, 6) + rng.randi_range(1, 6) - 2
	return rng.randi_range(0, board_length - 1)

func try_spawn_plants():
	for r in board_height:
		for c in board_length:
			var max_reach = max(wrs[c][0], wrs[c][1]) - 1
			if init_array[r][c] == 4 and tile_array[r][c] == 0 and max_reach < r:
				tile_array[r][c] |= 4

func create_wave():
	var col = get_flood_column()
	water_array[col] += 1
	wrs[col] = calculate_water_reach(col)
	check_grass_absorb(col)
	check_destroy_city(col)

func count_surviving_cities():
	var city_count = 0
	for rd in tile_array:
		for cd in rd:
			if cd & 2 > 0:
				city_count += 1
	return city_count

func process_game_tick():
	if tick_counter < tick_array.size() - 1:
		tick_counter += 1
		print("flooding %d%s" % [abs(tick_array[tick_counter]), ", try spawning plants" if tick_array[tick_counter] < 0 else ""])
		for i in abs(tick_array[tick_counter]):
			create_wave()
		if tick_array[tick_counter] < 0:
			try_spawn_plants()
	else:
		print("done; %d cities survived" % count_surviving_cities())

func get_next_tile_cycle(td, cur_step):
	match cur_step:
		0, 2 when td & 4 > 0:
			return 4
		0, 2 when td & 1 > 0:
			return 1
		0, 2:
			return 2
		4 when td & 1 > 0:
			return 1
		4 when td & 2 > 0:
			return 2
		4:
			return 4
		1 when td & 2 > 0:
			return 2
		1 when td & 4 > 0:
			return 4
		1:
			return 1

func cycleTile():
	var tile_val = tile_array[mouse_tile_position.y][mouse_tile_position.x]
	if tile_val == 0 and mouse_step == 0:
		return
	if mouse_step == 0:
		mouse_tile_selected = mouse_tile_position
		mouse_step = get_next_tile_cycle(tile_val, mouse_step)
		print("selected: ", tile_val)
	elif mouse_tile_selected == mouse_tile_position:
		mouse_step = get_next_tile_cycle(tile_val, mouse_step)
	elif tile_val & mouse_step > 0:
		mouse_tile_selected = mouse_tile_position
		mouse_step = get_next_tile_cycle(tile_val, 0)
		print("selected: ", tile_val)
	elif init_array[mouse_tile_position.y][mouse_tile_position.x] > 0:
		var max_reach = max(wrs[mouse_tile_position.x][0], wrs[mouse_tile_position.x][1]) - 1
		if max_reach < mouse_tile_position.y:
			tile_array[mouse_tile_position.y][mouse_tile_position.x] |= mouse_step
			tile_array[mouse_tile_selected.y][mouse_tile_selected.x] &= ~mouse_step
			mouse_step = 0;
			print("placed: ", tile_val)
